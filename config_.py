import yaml

class Config:
    def __init__(self, logger, mode='prod'):
        try:
            with open(f'./resource/application-{mode}.yml', 'r') as yml:
                cfg = yaml.safe_load(yml)
        except FileNotFoundError as e:
            logger.info(str(e) + '\nLoad default file application.yml')
            with open(f'./resource/application.yml', 'r') as yml:
                cfg = yaml.safe_load(yml)

        self.PathConfig = PathConfig(cfg)
        self.DBConfig = DBConfig(cfg)
        self.ESConfig = ESConfig(cfg)
        self.AtlanConfig = AtlanConfig(cfg)
        self.APIConfig = APIConfig(cfg)
        self.DefaultCodeConfig = DefaultCodeConfig(cfg)

class PathConfig:
    def __init__(self, cfg):
        path = cfg['PATH']
        self.SMART_SCH = path['SMART_SCH']
        self.GET_CARRIER_DATA_QUERY = path['GET_CARRIER_DATA_QUERY']

class DBConfig:
    def __init__(self, cfg):
        db_info = cfg['DB_INFO']
        self.HOST = db_info['HOST']
        self.PORT = db_info['PORT']
        self.USER = db_info['USER']
        self.PWD = db_info['PWD']
        self.DB = db_info['DB']

class ESConfig:
    def __init__(self, cfg):
        es_info = cfg['ES_INFO']
        self.HOST = es_info['HOST']
        self.PORT = es_info['PORT']
        self.INDEX_LIST = es_info['INDEX']


class AtlanConfig:
    def __init__(self, cfg):
        atl_api = cfg['ATLAN_API']
        self.base_url = atl_api['BASE_URL']
        self.key = atl_api['KEY']
        self.error_code_list = atl_api['ERROR_CODE']
        self.error_code_list = {str(k):v for k, v in self.error_code_list.items()}

class APIConfig:
    def __init__(self, cfg):
        api = cfg['API']
        self.push_noti_id_url = api['PUSH_NOTI_ID']['URL']
        self.push_carrier_url = api['PUSH_CARRIER']['URL']
        self.push_shipper_url = api['PUSH_SHIPPER']['URL']

class DefaultCodeConfig:
    def __init__(self, cfg):
        self.DEFAULT_CODE = cfg['DEFAULT_CODE']