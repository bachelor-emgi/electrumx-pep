# Copyright (c) 2016-2018, Neil Booth
# Copyright (c) 2018, the ElectrumX authors
#
# All rights reserved.
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

'''Deserializer for Dash DIP2 special transaction types'''

from dataclasses import dataclass
from typing import Any

from electrumx.lib.tx import Deserializer, Tx
from electrumx.lib.util import (pack_le_uint16, pack_le_int32, pack_le_uint32,
                                pack_le_int64, pack_varint, pack_varbytes,
                                pack_be_uint16)


# https://github.com/dashpay/dips/blob/master/dip-0002.md
@dataclass(kw_only=True, slots=True)
class DashTx(Tx):
    '''Class representing a Dash transaction'''
    tx_type: int
    extra_payload: Any

    def serialize(self):
        nLocktime = pack_le_uint32(self.locktime)
        txins = (pack_varint(len(self.inputs)) +
                 b''.join(tx_in.serialize() for tx_in in self.inputs))
        txouts = (pack_varint(len(self.outputs)) +
                  b''.join(tx_out.serialize() for tx_out in self.outputs))

        if self.tx_type:
            uVersion = pack_le_uint16(self.version)
            uTxType = pack_le_uint16(self.tx_type)
            vExtra = self._serialize_extra_payload()
            return uVersion + uTxType + txins + txouts + nLocktime + vExtra
        else:
            nVersion = pack_le_int32(self.version)
            return nVersion + txins + txouts + nLocktime

    def _serialize_extra_payload(self):
        extra = self.extra_payload
        spec_tx_class = DeserializerDash.SPEC_TX_HANDLERS.get(self.tx_type)
        if not spec_tx_class:
            assert isinstance(extra, (bytes, bytearray))
            return pack_varbytes(extra)

        if not isinstance(extra, spec_tx_class):
            raise ValueError('Dash tx_type does not conform with extra'
                             ' payload class: %s, %s' % (self.tx_type, extra))
        return pack_varbytes(extra.serialize())


# https://github.com/dashpay/dips/blob/master/dip-0002-special-transactions.md
@dataclass(kw_only=True, slots=True)
class DashProRegTx:
    '''Class representing DIP3 ProRegTx'''
    version: int
    type: int
    mode: int
    collateralOutpoint: 'TxOutPoint'
    ipAddress: bytes
    port: int
    KeyIdOwner: bytes
    PubKeyOperator: bytes
    KeyIdVoting: bytes
    operatorReward: int
    scriptPayout: bytes
    inputsHash: bytes
    platformNodeID: bytes
    platformP2PPort: int
    platformHTTPPort: int
    payloadSig: bytes

    def serialize(self):
        assert (len(self.ipAddress) == 16
                and len(self.KeyIdOwner) == 20
                and len(self.PubKeyOperator) == 48
                and len(self.KeyIdVoting) == 20
                and len(self.inputsHash) == 32)
        res = (
            pack_le_uint16(self.version) +                  # version
            pack_le_uint16(self.type) +                     # type
            pack_le_uint16(self.mode) +                     # mode
            self.collateralOutpoint.serialize() +           # collateralOutpoint
            self.ipAddress +                                # ipAddress
            pack_be_uint16(self.port) +                     # port
            self.KeyIdOwner +                               # KeyIdOwner
            self.PubKeyOperator +                           # PubKeyOperator
            self.KeyIdVoting +                              # KeyIdVoting
            pack_le_uint16(self.operatorReward) +           # operatorReward
            pack_varbytes(self.scriptPayout) +              # scriptPayout
            self.inputsHash)                                # inputsHash
        if self.version >= 2:
            res += (self.platformNodeID +                   # platformNodeID
                    pack_le_uint16(self.platformP2PPort) +  # platformP2PPort
                    pack_le_uint16(self.platformHTTPPort))  # platformHTTPPort
        res += pack_varbytes(self.payloadSig)               # payloadSig
        return res

    @classmethod
    def read_tx_extra(cls, deser):
        version = deser._read_le_uint16()               # version
        ntype = deser._read_le_uint16()                 # type
        mode = deser._read_le_uint16()                  # mode
        collateralOutpoint = deser._read_outpoint()     # collateralOutpoint
        ipAddress = deser._read_nbytes(16)              # ipAddress
        port = deser._read_be_uint16()                  # port
        KeyIdOwner = deser._read_nbytes(20)             # KeyIdOwner
        PubKeyOperator = deser._read_nbytes(48)         # PubKeyOperator
        KeyIdVoting = deser._read_nbytes(20)            # KeyIdVoting
        operatorReward = deser._read_le_uint16()        # operatorReward
        scriptPayout = deser._read_varbytes()           # scriptPayout
        inputsHash = deser._read_nbytes(32)             # inputsHash
        platformNodeID = b''
        platformP2PPort = 0
        platformHTTPPort = 0
        if version >= 2 and ntype == 1:
            platformNodeID = deser._read_nbytes(20)     # platformNodeID
            platformP2PPort = deser._read_le_uint16()   # platformP2PPort
            platformHTTPPort = deser._read_le_uint16()  # platformHTTPPort
        payloadSig = deser._read_varbytes()             # payloadSig
        return DashProRegTx(
            version=version,
            type=ntype,
            mode=mode,
            collateralOutpoint=collateralOutpoint,
            ipAddress=ipAddress,
            port=port,
            KeyIdOwner=KeyIdOwner,
            PubKeyOperator=PubKeyOperator,
            KeyIdVoting=KeyIdVoting,
            operatorReward=operatorReward,
            scriptPayout=scriptPayout,
            inputsHash=inputsHash,
            platformNodeID=platformNodeID,
            platformP2PPort=platformP2PPort,
            platformHTTPPort=platformHTTPPort,
            payloadSig=payloadSig,
        )


@dataclass(kw_only=True, slots=True)
class DashProUpServTx:
    '''Class representing DIP3 ProUpServTx'''
    version: int
    type: int
    proTxHash: bytes
    ipAddress: bytes
    port: int
    scriptOperatorPayout: bytes
    inputsHash: bytes
    platformNodeID: bytes
    platformP2PPort: int
    platformHTTPPort: int
    payloadSig: bytes

    def serialize(self):
        assert (len(self.proTxHash) == 32
                and len(self.ipAddress) == 16
                and len(self.inputsHash) == 32
                and len(self.payloadSig) == 96)
        res = pack_le_uint16(self.version)                  # version
        if self.version >= 2:
            res += pack_le_uint16(self.type)                # type
        res += (
            self.proTxHash +                                # proTxHash
            self.ipAddress +                                # ipAddress
            pack_be_uint16(self.port) +                     # port
            pack_varbytes(self.scriptOperatorPayout) +      # scriptOperatorPayout
            self.inputsHash)                                # inputsHash
        if self.version >= 2:
            res += (self.platformNodeID +                   # platformNodeID
                    pack_le_uint16(self.platformP2PPort) +  # platformP2PPort
                    pack_le_uint16(self.platformHTTPPort))  # platformHTTPPort
        res += self.payloadSig                              # payloadSig
        return res

    @classmethod
    def read_tx_extra(cls, deser):
        version = deser._read_le_uint16()                   # version
        ntype = 0
        if version >= 2:
            ntype = deser._read_le_uint16()                 # type
        proTxHash = deser._read_nbytes(32)                  # proTxHash
        ipAddress = deser._read_nbytes(16)                  # ipAddress
        port = deser._read_be_uint16()                      # port
        scriptOperatorPayout = deser._read_varbytes()       # scriptOperatorPayout
        inputsHash = deser._read_nbytes(32)                 # inputsHash
        platformNodeID = b''
        platformP2PPort = 0
        platformHTTPPort = 0
        if version >= 2 and ntype == 1:
            platformNodeID = deser._read_nbytes(20)         # platformNodeID
            platformP2PPort = deser._read_le_uint16()       # platformP2PPort
            platformHTTPPort = deser._read_le_uint16()      # platformHTTPPort
        payloadSig = deser._read_nbytes(96)                 # payloadSig
        return DashProUpServTx(
            version=version,
            type=ntype,
            proTxHash=proTxHash,
            ipAddress=ipAddress,
            port=port,
            scriptOperatorPayout=scriptOperatorPayout,
            inputsHash=inputsHash,
            platformNodeID=platformNodeID,
            platformP2PPort=platformP2PPort,
            platformHTTPPort=platformHTTPPort,
            payloadSig=payloadSig,
        )


@dataclass(kw_only=True, slots=True)
class DashProUpRegTx:
    '''Class representing DIP3 ProUpRegTx'''
    version: int
    proTxHash: bytes
    mode: int
    PubKeyOperator: bytes
    KeyIdVoting: bytes
    scriptPayout: bytes
    inputsHash: bytes
    payloadSig: bytes

    def serialize(self):
        assert (len(self.proTxHash) == 32
                and len(self.PubKeyOperator) == 48
                and len(self.KeyIdVoting) == 20
                and len(self.inputsHash) == 32)
        return (
            pack_le_uint16(self.version) +              # version
            self.proTxHash +                            # proTxHash
            pack_le_uint16(self.mode) +                 # mode
            self.PubKeyOperator +                       # PubKeyOperator
            self.KeyIdVoting +                          # KeyIdVoting
            pack_varbytes(self.scriptPayout) +          # scriptPayout
            self.inputsHash +                           # inputsHash
            pack_varbytes(self.payloadSig)              # payloadSig
        )

    @classmethod
    def read_tx_extra(cls, deser):
        return DashProUpRegTx(
            version=deser._read_le_uint16(),
            proTxHash=deser._read_nbytes(32),
            mode=deser._read_le_uint16(),
            PubKeyOperator=deser._read_nbytes(48),
            KeyIdVoting=deser._read_nbytes(20),
            scriptPayout=deser._read_varbytes(),
            inputsHash=deser._read_nbytes(32),
            payloadSig=deser._read_varbytes(),
        )


@dataclass(kw_only=True, slots=True)
class DashProUpRevTx:
    '''Class representing DIP3 ProUpRevTx'''
    version: int
    proTxHash: bytes
    reason: int
    inputsHash: bytes
    payloadSig: bytes

    def serialize(self):
        assert (len(self.proTxHash) == 32
                and len(self.inputsHash) == 32
                and len(self.payloadSig) == 96)
        return (
            pack_le_uint16(self.version) +              # version
            self.proTxHash +                            # proTxHash
            pack_le_uint16(self.reason) +               # reason
            self.inputsHash +                           # inputsHash
            self.payloadSig                             # payloadSig
        )

    @classmethod
    def read_tx_extra(cls, deser):
        return DashProUpRevTx(
            version=deser._read_le_uint16(),
            proTxHash=deser._read_nbytes(32),
            reason=deser._read_le_uint16(),
            inputsHash=deser._read_nbytes(32),
            payloadSig=deser._read_nbytes(96),
        )


@dataclass(kw_only=True, slots=True)
class DashCbTx:
    '''Class representing DIP4 coinbase special tx'''
    version: int
    height: int
    merkleRootMNList: bytes
    merkleRootQuorums: bytes
    bestCLHeightDiff: int
    bestCLSignature: bytes
    assetLockedAmount: int

    def serialize(self):
        assert len(self.merkleRootMNList) == 32
        res = (
            pack_le_uint16(self.version) +              # version
            pack_le_uint32(self.height) +               # height
            self.merkleRootMNList                       # merkleRootMNList
        )
        if self.version > 1:
            assert len(self.merkleRootQuorums) == 32
            res += self.merkleRootQuorums               # merkleRootQuorums
        if self.version > 2:
            res += pack_varint(self.bestCLHeightDiff)
            res += self.bestCLSignature
            res += pack_le_int64(self.assetLockedAmount)
        return res

    @classmethod
    def read_tx_extra(cls, deser):
        version = deser._read_le_uint16()
        height = deser._read_le_uint32()
        merkleRootMNList = deser._read_nbytes(32)
        merkleRootQuorums = b''
        bestCLHeightDiff = 0
        bestCLSignature = b''
        assetLockedAmount = 0
        if version > 1:
            merkleRootQuorums = deser._read_nbytes(32)
        if version > 2:
            bestCLHeightDiff = deser._read_varint()
            bestCLSignature = deser._read_nbytes(96)
            assetLockedAmount = deser._read_le_uint64()
        return DashCbTx(
            version=version,
            height=height,
            merkleRootMNList=merkleRootMNList,
            merkleRootQuorums=merkleRootQuorums,
            bestCLHeightDiff=bestCLHeightDiff,
            bestCLSignature=bestCLSignature,
            assetLockedAmount=assetLockedAmount,
        )


# https://dash-docs.github.io/en/developer-reference#outpoint
@dataclass(kw_only=True, slots=True)
class TxOutPoint:
    '''Class representing tx output outpoint'''
    hash: bytes
    index: int

    def serialize(self):
        assert len(self.hash) == 32
        return (
            self.hash +                                 # hash
            pack_le_uint32(self.index)                  # index
        )

    @classmethod
    def read_outpoint(cls, deser):
        return TxOutPoint(
            hash=deser._read_nbytes(32),
            index=deser._read_le_uint32(),
        )


class DeserializerDash(Deserializer):
    '''Deserializer for Dash DIP2 special tx types'''
    # Supported Spec Tx types and corresponding classes mapping
    PRO_REG_TX = 1
    PRO_UP_SERV_TX = 2
    PRO_UP_REG_TX = 3
    PRO_UP_REV_TX = 4
    CB_TX = 5

    SPEC_TX_HANDLERS = {
        PRO_REG_TX: DashProRegTx,
        PRO_UP_SERV_TX: DashProUpServTx,
        PRO_UP_REG_TX: DashProUpRegTx,
        PRO_UP_REV_TX: DashProUpRevTx,
        CB_TX: DashCbTx,
    }

    def _read_outpoint(self):
        return TxOutPoint.read_outpoint(self)

    def read_tx(self):
        start = self.cursor
        header = self._read_le_uint32()
        tx_type = header >> 16  # DIP2 tx type
        if tx_type:
            version = header & 0x0000ffff
        else:
            version = header

        if tx_type and version < 3:
            version = header
            tx_type = 0

        inputs = self._read_inputs()
        outputs = self._read_outputs()
        locktime = self._read_le_uint32()
        if tx_type:
            extra_payload_size = self._read_varint()
            end = self.cursor + extra_payload_size
            spec_tx_class = DeserializerDash.SPEC_TX_HANDLERS.get(tx_type)
            if spec_tx_class:
                read_method = getattr(spec_tx_class, 'read_tx_extra', None)
                extra_payload = read_method(self)
                assert isinstance(extra_payload, spec_tx_class)
            else:
                extra_payload = self._read_nbytes(extra_payload_size)
            assert self.cursor == end
        else:
            extra_payload = b''
        txid = self.TX_HASH_FN(self.binary[start:self.cursor])
        tx = DashTx(
            version=version,
            inputs=inputs,
            outputs=outputs,
            locktime=locktime,
            tx_type=tx_type,
            extra_payload=extra_payload,
            txid=txid,
            wtxid=txid,
        )
        return tx