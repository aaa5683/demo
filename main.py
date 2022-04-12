import argparse
from src.logger import CreateLogger
from config import Config
from datetime import datetime, timedelta


def main(logger, cfg):
    try:
        task = args.task if 'args' in locals() else 'img'
        logger.info(f'Demo for Task "{task}"')

        if task=='img':
            video_path = 'data/video/iu_concert.mp4'

            # get frames from video

            #

    except Exception as e:
        logger.error(f'[ERROR] {str(e)}')



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Demo for SmartNIC')
    parser.add_argument('--task', default='img', choices=['img', 'viedo', '4k_streaming'], help='task to do')
    args = parser.parse_args()

    logger = CreateLogger(logger_name='main', loggfile_path='main.log')
    start_tms = datetime.now()

    logger.info('< START >')
    cfg = Config(args, logger)
    main(logger, cfg)