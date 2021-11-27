# from os import getenv
# from dotenv import load_dotenv
import requests
import re
from typing import List, Optional


# Load environment variables
#load_dotenv()


# Crawling (CPU from geekbench)
class CPU:
    name: str = None
    architecture: str = 'x86'
    brand: str = None
    score: int = None
    score_source: str = None

response = requests.get('https://browser.geekbench.com/processor-benchmarks.json').json()
count = len(response['devices'])

print(f'Info: Crawling CPU from geekbench done! {count} of processors found.')

cpu_list: List[CPU] = []

for device in response['devices']:
    cpu = CPU()
    cpu.name = device['name']
    cpu.score = device['multicore_score']
    cpu.brand = device['name'].split(' ')[0]
    cpu.score_source = 'Geekbench'

    try:
        assert cpu.brand == 'Intel' or cpu.brand == 'AMD', f'CPU "{cpu.name}" brand is not one of: Intel, AMD'
    except AssertionError as e:
        print('Note:', e)
        continue

    cpu_list.append(cpu)


# Crawling (GPU from geekbench)
class GPU:
    name: str = None
    brand: str = None
    score: int = None
    score_source: str = None

response = requests.get('https://browser.geekbench.com/opencl-benchmarks.json').json()
count = len(response['devices'])

print(f'Info: Crawling GPU from geekbench done! {count} of processors found.')

gpu_list: List[GPU] = []

for device in response['devices']:
    gpu = GPU()
    gpu.name = device['name']
    gpu.score = device['score']
    gpu.brand = None
    gpu.score_source = 'Geekbench'
    
    if 'Apple' in gpu.name:
        gpu.brand = 'Apple'
    elif 'AMD' in gpu.name or 'Radeon' in gpu.name or 'ATI' in gpu.name or 'Vega' in gpu.name:
        gpu.brand = 'AMD'
    elif 'Intel' in gpu.name or 'Iris' in gpu.name or 'HD Graphics' in gpu.name:
        gpu.brand = 'Intel'
    elif 'NVIDIA' in gpu.name or 'GeForce' in gpu.name or 'GTX' in gpu.name or 'RTX' in gpu.name \
        or 'TITAN' in gpu.name or 'Quadro' in gpu.name or 'Tesla' in gpu.name:
        gpu.brand = 'Nvidia'
    
    if gpu.brand is None:
        print(f'Note: GPU "{gpu.name}" brand is not one of: Nvidia, AMD, Intel, Apple')
        continue

    gpu_list.append(gpu)


# Crawling (Laptops from danawa)
from stcomputer_collector.collectors import DanawaCollector
from stcomputer_collector.product import ProductSpec
from stcomputer_collector.provider.base.session import Session
from stcomputer_collector.provider.danawa.session import DanawaSession


class DanawaLaptopCollector(DanawaCollector):
    def do_collect(self, session: Session, page: int) -> Optional[List[ProductSpec]]:
        product_specs = []
        session.load_from_query('노트북', page)

        for raw_product_spec in session.get_product_specs():
            if raw_product_spec.category[-2:] != ['노트북', '노트북 전체']:
                print(f'Note: Skip "{raw_product_spec.name}" is not a laptop')
                continue
        
            product_spec = ProductSpec(raw_product_spec)
            product_specs.append(product_spec)
        
        return product_specs


driver = requests.Session()
driver.headers.update({
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15',
})
collector = DanawaLaptopCollector(DanawaSession(driver))

class Laptop:
    id: str = None
    name: str = None
    thumbnail: str = None
    brand: str = None
    registration_date: str = None
    cpu_name: str = None
    gpu_name: str = None
    ram: int = None
    os: str = None
    display: str = None
    display_ratio: str = 'unknown'
    resolution: str = None
    weight: str = None

    cpu_brand: str = None
    variants: List['LaptopVariant']


class LaptopVariant:
    id: str = None
    name: str = None
    price: str = None

laptop_list: List[Laptop] = []

for batch_product_specs in collector.collect(8):
    for product_spec in batch_product_specs:
        laptop = Laptop()
        laptop.id = product_spec.id
        laptop.name = product_spec.name
        laptop.thumbnail = product_spec.thumbnail
        laptop.brand = product_spec.name.split(' ')[0]
        laptop.registration_date = product_spec.registration_date.strftime('%Y-%m-%d')
        laptop.variants = []

        for product in product_spec.products:
            variant = LaptopVariant()
            variant.id = product.id
            variant.name = product.variant
            variant.price = product.price
            laptop.variants.append(variant)

        print(f'Debug: Product "{laptop.name}" has {len(laptop.variants)} options.')

        # Find cpu name from tags
        for i, tag in enumerate(product_spec.tags):

            # ex) 8192
            if tag.startswith('메모리:'):
                laptop.ram = int(re.search(r'(\d+)GB$', tag).group(1)) * 1024

            # ex) 1.81kg
            elif tag.startswith('무게:'):
                result = re.search(r'((?:\d+\.)?\d+)(k?g)$', tag)
                laptop.weight = result.group(0)

                if result.group(2) == 'g':
                    laptop.weight = f'{int(result.group(1)) / 1000}kg'

            # ex) Windows
            elif tag.startswith('운영체제(OS):'):
                if re.search(r'미포함', tag):
                    laptop.os = 'Free DOS'
                elif re.search(r'윈도우', tag):
                    laptop.os = 'Windows'
                elif re.search(r'mac', tag):
                    laptop.os = 'Mac OS'
                elif re.search(r'리눅스', tag):
                    laptop.os = 'Linux'

            # ex) 17.3인치
            elif (result := re.search(r'(?:\d+\.)?\d+인치', tag)):
                laptop.display = result.group(0)

            # ex) 1920x1080(FHD)
            elif (result := re.search(r'\d+x\d+', tag)):
                laptop.resolution = result.group(0)

            # ex) i7-9700K
            elif re.search(r'\(\d+\.\d+GHz\)$', tag):
                laptop.cpu_name = tag.split(' ')[0]
            
            # ex) RTX3070
            elif tag == '외장그래픽':
                laptop.gpu_name = product_spec.tags[i + 1]
            
            # ex) Intel
            elif tag == '인텔':
                laptop.cpu_brand = 'Intel'
            elif tag == 'AMD':
                laptop.cpu_brand = 'AMD'
            elif tag == '애플(ARM)':
                laptop.cpu_brand = 'Apple'
        
        # We should resolve cpu, gpu from geekbench

        # resolve CPU
        if laptop.cpu_name is None:
            print(f'Note: Could not resolve cpu name.')
            continue

        laptop.cpu_name = laptop.cpu_name.lower()
        resolved = False

        for cpu in cpu_list:
            if cpu.brand == laptop.cpu_brand and laptop.cpu_name in cpu.name.lower():
                laptop.cpu_name = cpu.name
                resolved = True
                break
        
        if not resolved:
            print(f'Note: Couldnt resolve cpu from geekbench. cpu_name={laptop.cpu_name}')
            continue

        # resolve GPU (if graphics card exists)
        if laptop.gpu_name is not None:
            laptop.gpu_name = laptop.gpu_name.lower().replace(' ', '')
            resolved = False

            for gpu in gpu_list:
                # search without blank
                if laptop.gpu_name in gpu.name.lower().replace(' ', ''):
                    laptop.gpu_name = gpu.name
                    resolved = True
                    break
            
            if not resolved:
                print(f'Note: Couldnt resolve gpu from geekbench. gpu_name={laptop.gpu_name}')
                continue

        # successfully parsed!
        laptop_list.append(laptop)


# serialize as json, and save to outputs/ directory
import jsonpickle

jsonpickle.set_preferred_backend('json')
jsonpickle.set_encoder_options('json', ensure_ascii=False)

for filename, data in [('cpu', cpu_list), ('gpu', gpu_list), ('laptop', laptop_list)]:
    with open(f'outputs/{filename}.json', 'w', encoding='UTF-8') as file:
        file.write(jsonpickle.encode(data, unpicklable=False, indent=4))

print('Info: Complete json serialization.')


# Convert to sql queries
with open('result.sql', 'w', encoding='UTF-8') as file:
    # Some stuffs
    print("SET DEFINE OFF;", file=file)
    
    print('\n\n', file=file)

    for os in ['Windows', 'Mac OS', 'Linux', 'Free DOS']:
        print("INSERT INTO 운영체제 VALUES('{}');".format(os), file=file)
    
    print('\n\n', file=file)

    for cpu in cpu_list:
        print("INSERT INTO CPU VALUES ('{}', '{}', '{}', {}, '{}');".format(
            cpu.name,
            cpu.architecture,
            cpu.brand,
            cpu.score,
            cpu.score_source,
        ), file=file)
    
    print('\n\n', file=file)

    for gpu in gpu_list:
        print("INSERT INTO GPU VALUES ('{}', '{}', {}, '{}');".format(
            gpu.name,
            gpu.brand,
            gpu.score,
            gpu.score_source
        ), file=file)
    
    print('\n\n', file=file)

    for laptop in laptop_list:
        print("INSERT INTO 제품정보 VALUES ('{}', '{}', '{}', '{}', '{}', '{}', {}, {}, '{}', '{}', '{}', '{}', '{}');".format(
            laptop.id,
            laptop.name,
            laptop.thumbnail,
            laptop.brand,
            laptop.registration_date,
            laptop.cpu_name,
            'NULL' if laptop.gpu_name is None else f"'{laptop.gpu_name}'",
            laptop.ram,
            laptop.os,
            laptop.display,
            laptop.display_ratio,
            laptop.resolution,
            laptop.weight,
        ), file=file)

    print('\n\n', file=file)

    for laptop in laptop_list:
        for variant in laptop.variants:
            print("INSERT INTO 제품옵션 VALUES ('{}', '{}', '{}', {});".format(
                variant.id,
                laptop.id,
                variant.name,
                'NULL' if variant.price is None else variant.price,
            ), file=file)

print('Info: Complete SQL serialization.')


# Print some unresolved gpu list (Integrated GPU)
integrated_cpu_list = set()
for laptop in laptop_list:
    if laptop.gpu_name is None:
        integrated_cpu_list.add(laptop.cpu_name)

print('Warning: Unresolved integrated GPU needs geekbench data. Please note.')
for cpu_name in integrated_cpu_list:
    print('\t' + cpu_name)


# Setup database with SQLAlchemy
# from sqlalchemy.engine import create_engine

# DIALECT = 'oracle'
# SQL_DRIVER = 'cx_oracle'
# USERNAME = getenv('USERNAME', 'LAPTOPMAN')
# PASSWORD = getenv('PASSWORD')
# HOST = getenv('HOST')
# PORT = getenv('PORT', 1521)
# SERVICE = getenv('SERVICE', 'xe')

# ENGINE_PATH_WIN_AUTH = f'{DIALECT}+{SQL_DRIVER}://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/?service_name={SERVICE}'

# engine = create_engine(ENGINE_PATH_WIN_AUTH)
