import os

from web3 import Web3
from pydash import get
# from dotenv import load_dotenv

# load_dotenv()

_privateKeySigner = "98102796d0dfe116f5af6e9a3c10dc38d316f6c98b3ded8d008b962c7d126460"
_user_address = "0xaDF66a56f668Bd18C598af93207330273E62ccA8"

# arb
# _contract_address = "0xBA6BCCb229E49a540c6c59fF92236a2E7a4608e5"

# goerli
_contract_address = "0x9F55fCe03779C06f0421d026dcCE0D8d6fF8a086"

ETHER_GOERLI = 5
ARB_TEST = 421613

_data = {
    "chain_network": ETHER_GOERLI,
    "amount": 999, 
    "deadline": 1688964733
}
# getChainID(),
# tx.origin,
# address(this),
# _txHash,
# _amount,
# _proof.deadline
def generate_signature():
    _w3 = Web3()
    _encode = _w3.codec.encode_abi(
        [
            'uint256', # chain
            'address', # _user_address
            'address', # contract bridge
            'string', # transaction hash
            'uint256', # amount
            'uint256' # deadline
        ], 
        [
            get(_data, "chain_network"),
            _user_address,
            _contract_address,
            "0x7aa60a6c17d345aad75f74e9887c29c37a2d113797e06d5c9b4ed619b6cb0e78",
            get(_data, "amount"), # amount
            get(_data, "deadline")
        ]
    )
    
    digest = Web3.solidityKeccak(['bytes'], [f'0x{_encode.hex()}'])
    _signed_message = _w3.eth.account.signHash(
        digest,
        private_key=_privateKeySigner
    )

    return _signed_message.signature.hex()

print("* Signature = ", generate_signature())


# base = 0x5a0b849136aa2b8b822342934bad251c191c4cb1bc57770af734e7e868ac03df70c17ee5659b97121b02dfc8ab3786b7940adb07a00269d187a495af2a7766821c