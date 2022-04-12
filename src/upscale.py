import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img, array_to_img, img_to_array
import os
import argparse
from tqdm import tqdm
from PIL import Image, ImageDraw, ImageFont
import numpy as np
from src.logger import CreateLogger


def concat_image(img_dict, vertical=False, font_path='resource/fonts/KakaoBold.ttf'):
    fnt = ImageFont.truetype(font=font_path, size=30)
    accum = 0

    if vertical:
        new_w = list(img_dict.values())[0].width
        new_h = sum([v.height for k,v in img_dict.items()])
        dst = Image.new('RGB', (new_w, new_h))
        for k,v in img_dict.items():
            draw = ImageDraw.Draw(v)
            draw.text(xy=(10, 10), text=k, fill='white', font=fnt)
            dst.paste(v, (0, accum))
            accum += v.height

    else: # horizontal
        new_w = sum([v.width for k, v in img_dict.items()])
        new_h = list(img_dict.values())[0].height
        dst = Image.new('RGB', (new_w, new_h))
        for k, v in img_dict.items():
            draw = ImageDraw.Draw(v)
            draw.text(xy=(10, 10), text=k, fill='white', font=fnt)
            dst.paste(v, (accum, 0))
            accum += v.width


    return dst


def get_lowres_image(img, upscale_factor):
    return img.resize(
        (img.size[0] // upscale_factor, img.size[1] // upscale_factor),
        Image.BICUBIC,
        )


def upscaling(model, img):

    ycbcr = img.convert("YCbCr")
    y, cb, cr = ycbcr.split()
    y = img_to_array(y)
    y = y.astype("float32") / 255.0

    input = np.expand_dims(y, axis=0)
    out = model.predict(input)

    out_img_y = out[0]
    out_img_y *= 255.0

    # Restore the image in RGB color space.
    out_img_y = out_img_y.clip(0, 255)
    out_img_y = out_img_y.reshape((np.shape(out_img_y)[0], np.shape(out_img_y)[1]))
    out_img_y = Image.fromarray(np.uint8(out_img_y), mode="L")
    out_img_cb = cb.resize(out_img_y.size, Image.BICUBIC)
    out_img_cr = cr.resize(out_img_y.size, Image.BICUBIC)
    out_img = Image.merge("YCbCr", (out_img_y, out_img_cb, out_img_cr)).convert("RGB")

    return out_img


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--model_path', '-m', default='models/iu1_360p_134_20220411_1906', type=str)
    parser.add_argument('--img_path', '-i', default='data/frame', type=str)
    parser.add_argument('--upscal_img_path', '-u', default='data/sr_frame', type=str)
    parser.add_argument('--upscale_factor', default=3, type=int)
    args = parser.parse_args()

    logger = CreateLogger(logger_name='upscaling', loggfile_path='log/upscaling.log')

    model_path = args.model_path if 'args' in locals() else 'models/iu1_360p_134_20220411_1906'
    img_path = args.img_path if 'args' in locals() else 'data/frame'
    upscale_img_path = args.upscal_img_path if 'args' in locals() else 'data/sr_frame'
    upscale_factor = args.upscale_factor if 'args' in locals() else 3

    model = tf.keras.models.load_model(model_path)
    frames_path = os.listdir(img_path)

    total_bicubic_psnr = 0.0
    total_test_psnr = 0.0

    for index, frame_name in enumerate(tqdm(frames_path)):
        img = load_img(os.path.join(img_path, frame_name))
        low_input = get_lowres_image(img, upscale_factor)
        w = low_input.size[0] * upscale_factor
        h = low_input.size[1] * upscale_factor

        high_img = img.resize((w, h))
        predict_img = upscaling(model, low_input)
        low_img = low_input.resize((w, h))

        low_img_arr = img_to_array(low_img)
        high_img_arr = img_to_array(high_img)
        predict_img_arr = img_to_array(predict_img)

        bicubic_psnr = tf.image.psnr(low_img_arr, high_img_arr, max_val=255)
        test_psnr = tf.image.psnr(predict_img_arr, high_img_arr, max_val=255)

        total_bicubic_psnr += bicubic_psnr
        total_test_psnr += test_psnr

        logger.info(f'PSNR ( low - high ) : {bicubic_psnr}')
        logger.info(f'PSNR ( predict - high ) : {test_psnr}')

        dst = concat_image(img_dict={'high': high_img, 'low':low_img, 'predict': predict_img}, vertical=False)
        dst.save(os.path.join(upscale_img_path, frame_name), 'JPEG')

