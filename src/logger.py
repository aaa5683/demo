import logging
import logging.handlers

def CreateLogger(logger_name, loggfile_path):
    logger = logging.getLogger(logger_name)
    if len(logger.handlers) > 0:
        return logger
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter('[%(levelname)s|%(name)s|%(filename)s:%(lineno)s] %(asctime)s > %(message)s')
    # Create Handlers
    streamHandler = logging.StreamHandler()
    streamHandler.setLevel(logging.DEBUG)
    streamHandler.setFormatter(formatter)

    # fileHandler = logging.FileHandler(loggfile_path)
    # fileHandler = logging.handlers.TimedRotatingFileHandler(filename=loggfile_path,
    #                                                         when='D',
    #                                                         interval=7,
    #                                                         backupCount=1,
    #                                                         encoding='utf-8')
    fileHandler = logging.handlers.RotatingFileHandler(filename=loggfile_path,
                                                       maxBytes=10 * 1024 * 1024, # 10 MB
                                                       backupCount=3,
                                                       encoding='utf-8')

    fileHandler.setLevel(logging.DEBUG)
    fileHandler.setFormatter(formatter)

    logger.addHandler(streamHandler)
    logger.addHandler(fileHandler)

    return logger