import os

from web3 import Web3
from pydash import get
# from dotenv import load_dotenv

# load_dotenv()

_privateKeySigner = "769b7857a2faaa241615de70b8e87b2e491e26bdf0bde6625f93d23dad062d0e"
_privateKeySigner2 = "f93eba4dd3d5dca4aef41bca3998532c11c24fc8472cb649a72acbd8232c493e"
_privateKeySigner3 = "7a4cf5034f50d3d38a0602457b92f206bc9ecfa82fe795160cb10357f339db7c"
_privateKeySigner4 = "bea398bd816c2e72605e20086f33a3ca1470d24f65bc2356ce3b5558e2958c86"
_privateKeySigner5 = "7a7271b40429a8c77b4a2d254734ed9753f1c0cfa0763f403fa8ab6140ad0a3b"

# 769b7857a2faaa241615de70b8e87b2e491e26bdf0bde6625f93d23dad062d0e : 0x8BC0073828fCFFebaCFBa058e47ec276A15fecfB

# f93eba4dd3d5dca4aef41bca3998532c11c24fc8472cb649a72acbd8232c493e : 0x70fb92cC9389fF80E51868067f0E2f47Cbd6C63F

# 7a4cf5034f50d3d38a0602457b92f206bc9ecfa82fe795160cb10357f339db7c : 0x9CAdcdA4752E8929D815945B4F4aBa0B0Cec05cF

# bea398bd816c2e72605e20086f33a3ca1470d24f65bc2356ce3b5558e2958c86 : 0x63B9C930A19638AD4b72dfec64ab1b34b1bdd9E9

# 7a7271b40429a8c77b4a2d254734ed9753f1c0cfa0763f403fa8ab6140ad0a3b  : 0x5421FCeDccA8023393C74a1038c34D23293c6384


_user_address = "0xE4A482E15Bd8D5cAEf13B2f0EfdE7Bf15B737929"

_contract_address = "0x63084Efb344B68ecf35AAE1Ea0E7D10DD09740A0"




# # Ether
# BridgePool=0x3739d05719AEdD25209C373B449D61B22FB77fA0
# MemBridge=0x9590440dbF366d7058cc7EFdE87eDE5C6f87E8dA

ETHER_GOERLI = 5
ARB_TEST = 421613

_data = {
    "chain_network": ARB_TEST,
    "amount": 100, 
    "deadline": 1688964733
}
# getChainID(),
# tx.origin,
# address(this),
# _txHash,
# _amount,
# _proof.deadline
def generate_signature(_privateKey):
    _w3 = Web3()
    _encode = _w3.codec.encode_abi(
        [
            'uint256', # To chainID
            'uint256', # From chainID
            'address', # _user_address
            'address', # contract bridge
            'string', # transaction hash
            'uint256' # amount
        ], 
        [
            get(_data, "chain_network"),
            5,
            _user_address,
            _contract_address,
            "0x7aa60a6c17d345aad75f74e9887c29c37a2d113797e06d5c9b4ed619b6cb0e7c",
            get(_data, "amount")
        ]
    )
    
    digest = Web3.solidityKeccak(['bytes'], [f'0x{_encode.hex()}'])
    _signed_message = _w3.eth.account.signHash(
        digest,
        private_key=_privateKey
    )

    return _signed_message.signature.hex()


print(f'Signature = "{generate_signature(_privateKeySigner)}"')
print(f'Signature2 = "{generate_signature(_privateKeySigner2)}"')
print(f'Signature3 = "{generate_signature(_privateKeySigner3)}"')
print(f'Signature4 = "{generate_signature(_privateKeySigner4)}"')
print(f'Signature5 = "{generate_signature(_privateKeySigner5)}"')


# base = 0x5a0b849136aa2b8b822342934bad251c191c4cb1bc57770af734e7e868ac03df70c17ee5659b97121b02dfc8ab3786b7940adb07a00269d187a495af2a7766821c