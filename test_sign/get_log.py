# from web3 import Web3
import web3
import json


# web3 = Web3(Web3.HTTPProvider('https://goerli-rollup.arbitrum.io/rpc'))

from decimal import Decimal

def covert(amount):
    #: Convert gwei to wei
    
    return web3.utils.toWei(amount)

if __name__ == "__main__":
    a = covert('0.040')
    b = covert('0.035')
    print(a)
    print(a - b)