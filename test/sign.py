import os

from web3 import Web3
from pydash import get
# from dotenv import load_dotenv

# load_dotenv()

_privateKeySigner = "98102796d0dfe116f5af6e9a3c10dc38d316f6c98b3ded8d008b962c7d126460"
_user_address = "0xE4A482E15Bd8D5cAEf13B2f0EfdE7Bf15B737929"

_contract_address = "0x9590440dbF366d7058cc7EFdE87eDE5C6f87E8dA"

# ARB
# LadysToken=0xA3375db815d30f2f0da391c6a94D5c872e939bC9
# BridgePool=0xF5945449b27532BCe9519Bc032a6cb73Fe09d2E7
# MemBridge=0x95c18Acb2737802528Abe7be546De3ef39FE48B5


# # Ether
# BridgePool=0x3739d05719AEdD25209C373B449D61B22FB77fA0
# MemBridge=0x9590440dbF366d7058cc7EFdE87eDE5C6f87E8dA

ETHER_GOERLI = 5
ARB_TEST = 421613

_data = {
    "chain_network": ETHER_GOERLI,
    "amount": 1000, 
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