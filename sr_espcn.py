import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.models import load_model
import numpy as np
import PIL
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1.inset_locator import zoomed_inset_axes
from mpl_toolkits.axes_grid1.inset_locator import mark_inset
from tqdm import tqdm
from src.logger import CreateLogger


class ESPN:
    def __init__(self, logger, model_nm, upscale_factor=3):
        self.logger = logger
        self.model_path=f'models/{model_nm}'
        self.upscale_factor = upscale_factor
        self.img_path='data/frame'
        self.sr_img_path='data/sr_frame'
        self.img_path_list = os.listdir(self.img_path)
        self.model = None

    def upscale_image(self, img):
        """Predict the result based on input image and restore the image as RGB."""
        ycbcr = img.convert("YCbCr")
        y, cb, cr = ycbcr.split()
        y = img_to_array(y)
        y = y.astype("float32") / 255.0

        input = np.expand_dims(y, axis=0)
        out = self.model.predict(input)

        out_img_y = out[0]
        out_img_y *= 255.0

        # Restore the image in RGB color space.
        out_img_y = out_img_y.clip(0, 255)
        out_img_y = out_img_y.reshape((np.shape(out_img_y)[0], np.shape(out_img_y)[1]))
        out_img_y = PIL.Image.fromarray(np.uint8(out_img_y), mode="L")
        out_img_cb = cb.resize(out_img_y.size, PIL.Image.BICUBIC)
        out_img_cr = cr.resize(out_img_y.size, PIL.Image.BICUBIC)
        out_img = PIL.Image.merge("YCbCr", (out_img_y, out_img_cb, out_img_cr)).convert(
            "RGB"
        )
        return out_img

    def get_low_image(self, img):
        """Return low-resolution image to use as model input."""
        return img.resize(
            (img.size[0] // self.upscale_factor, img.size[1] // self.upscale_factor),
            PIL.Image.BICUBIC,
        )

    def upscaling(self):
        self.model = load_model(self.model_path)
        print(self.model.summary())

        total_bicubic_psnr = 0.0
        total_test_psnr = 0.0
        for img_path in tqdm(self.img_path_list):
            img = load_img(os.path.join('data/frame', img_path))
            low_input = self.get_low_image(img)
            w = low_input.size[0] * self.upscale_factor
            h = low_input.size[1] * self.upscale_factor
            high_img = img.resize((w, h))
            predict_img = self.upscale_image(low_input)
            low_img = low_input.resize((w, h))
            low_img_arr = img_to_array(low_img)
            high_img_arr = img_to_array(high_img)
            predict_img_arr = img_to_array(predict_img)
            bicubic_psnr = tf.image.psnr(low_img_arr, high_img_arr, max_val=255)
            test_psnr = tf.image.psnr(predict_img_arr, high_img_arr, max_val=255)

            total_bicubic_psnr += bicubic_psnr
            total_test_psnr += test_psnr

            # self.logger.info(f'PSNR of low resolution image and high resolution image is {bicubic_psnr}')
            # self.logger.info(f'PSNR of predict and high resolution is {test_psnr}')

            low_img.save(os.path.join(self.sr_img_path, f'{img_path.split(".")[0]}_low.jpg'), 'jpeg')
            high_img.save(os.path.join(self.sr_img_path, f'{img_path.split(".")[0]}_high.jpg'), 'jpeg')
            predict_img.save(os.path.join(self.sr_img_path, f'{img_path.split(".")[0]}_predict.jpg'), 'jpeg')

            # self.plot_results(low_img, test_img_path.split('/')[-1], "low")
            # self.plot_results(high_img, test_img_path.split('/')[-1], "high")
            # self.plot_results(predict_img, test_img_path.split('/')[-1], "prediction")

    def plot_results(self, img, prefix, title, save_base_path='predict_test_images'):
        """Plot the result with zoom-in area."""
        img_array = img_to_array(img)
        img_array = img_array.astype("float32") / 255.0

        # Create a new figure with a default 111 subplot.
        fig, ax = plt.subplots()
        im = ax.imshow(img_array[::-1], origin="lower")

        plt.title(title)
        # zoom-factor: 2.0, location: upper-left
        axins = zoomed_inset_axes(ax, 2, loc=2)
        axins.imshow(img_array[::-1], origin="lower")

        # Specify the limits.
        x1, x2, y1, y2 = 200, 300, 100, 200
        # Apply the x-limits.
        axins.set_xlim(x1, x2)
        # Apply the y-limits.
        axins.set_ylim(y1, y2)

        plt.yticks(visible=False)
        plt.xticks(visible=False)

        # Make the line.
        mark_inset(ax, axins, loc1=1, loc2=3, fc="none", ec="blue")
        plt.savefig(f'{save_base_path}/' + str(prefix) + "-" + title + ".png")
        plt.show()
        plt.close('all')



if __name__ == '__main__':
    logger = CreateLogger(logger_name='espcn_obj', loggfile_path='log/espcn_obj.log')
    my_sr = ESPN(logger=logger, model_nm='mymodel_20220411_1302')

    # my_sr.model = load_model(my_sr.model_path)
    my_sr.upscaling()