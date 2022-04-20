import warnings
warnings.simplefilter('ignore')
import cv2
import os
from logger import CreateLogger
import argparse
from screeninfo import get_monitors

class Display:
    def __init__(self, logger=None, ms=300):
        self.ms = ms
        myscreen = [s for s in get_monitors() if s.is_primary][0]
        self.screen_size = (myscreen.width, myscreen.height)
        self.screen_center_loc = (self.screen_size[0]//2, self.screen_size[-1]//2)
        self.logger = CreateLogger(logger_name='Display', loggfile_path='log/Display.log') if logger is None else logger

    def display(self, path):
        if not os.path.exists(path):
            self.logger.error(f'[ERROR] there is no {path}.')

        else:
            if os.path.isfile(path):
                self.logger.info('single file')
                img = cv2.imread(path, cv2.IMREAD_COLOR)
                winname = f'{path} : {img.shape}'
                cv2.namedWindow(winname)
                cv2.moveWindow(winname, self.screen_center_loc[0], self.screen_center_loc[-1])
                cv2.imshow(winname, img)
                cv2.waitKey(self.ms)
                cv2.destroyAllWindows()
                cv2.waitKey(1)

            else:
                self.logger.info('display all file in directory')
                file_list = sorted(os.listdir(path))
                for f in file_list:
                    if f=='.DS_Store':
                        continue
                    img = cv2.imread(os.path.join(path, f), cv2.IMREAD_COLOR)
                    winname = f'{os.path.join(path, f)} : {img.shape}'
                    cv2.namedWindow(winname)
                    cv2.moveWindow(winname, self.screen_center_loc[0], self.screen_center_loc[-1])
                    cv2.imshow(winname, img)
                    cv2.imshow(winname, img)
                    cv2.waitKey(self.ms)
                    cv2.destroyAllWindows()
                    cv2.waitKey(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Dispaly images & videos')
    parser.add_argument('--path', type=str, help='file path to display')
    args = parser.parse_args()

    ds = Display()
    ds.display(path=args.path)