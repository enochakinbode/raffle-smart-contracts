# pragma version ^0.4.0
# @license Unlicense

"""
@title A Simple Raffle/Lottery Contract
@author enochakinbode
"""

import interfaces.VrfV2PlusWrapper as VrfV2PlusWrapper
import libraries.VRFV2PlusClient as VRFV2PlusClient


event Raffle__TicketPurchased:
    purchaser: address
    num_tickets: uint256

event Raffle__RandomnessRequested:
    request_id: indexed(uint256)

event Raffle__EpochCompleted:
    epoch_num: indexed(uint256)
    winner: indexed(address)
    winning_ticket: uint256
    reward: uint256
    num_tickets: uint256

event Raffle__EpochSkipped:
    epoch_num: indexed(uint256)


MAX_TICKETS: constant(uint256) = 1000
INTERVAL: constant(uint256) = 300  # 5 minutes

owner: public(address)
entrance_fee: public(uint256)
vrf_v2_plus_wrapper: immutable(VrfV2PlusWrapper)

is_picking_winner: public(bool)
current_epoch: public(uint256)
total_tickets_in_current_epoch: public(uint256)
epoch_start_time: public(uint256)
tickets: public(HashMap[uint256, HashMap[uint256, address]])  # epoch -> ticket_id -> address


    
@deploy
def __init__(_entrance_fee: uint256, _vrf_v2_plus_wrapper: address):
    self.entrance_fee = _entrance_fee
    self.owner = msg.sender
    self.epoch_start_time = block.timestamp
    vrf_v2_plus_wrapper = VrfV2PlusWrapper(_vrf_v2_plus_wrapper)


@external
@payable
def enter_raffle():
    assert (block.timestamp - self.epoch_start_time) <= INTERVAL, "raffle not open"

    tickets_to_purchase: uint256 = msg.value // self.entrance_fee
    assert tickets_to_purchase > 0, "not enough eth sent"

    for _: uint256 in range(tickets_to_purchase, bound=MAX_TICKETS):
        self.tickets[self.current_epoch][self.total_tickets_in_current_epoch] = msg.sender
        self.total_tickets_in_current_epoch += 1

    excess: uint256 = msg.value % self.entrance_fee
    if excess > 0:
        send(msg.sender, excess)

    log Raffle__TicketPurchased(purchaser=msg.sender, num_tickets=tickets_to_purchase)


@external
@view
def checkUpkeep(check_data: Bytes[32]) -> (bool, Bytes[32]):
    expired: bool = (block.timestamp - self.epoch_start_time) > INTERVAL
    upkeep_needed: bool = expired and not self.is_picking_winner
    return (upkeep_needed, b"\x00")


@external
def performUpkeep(perform_data: Bytes[32]):
    upkeep_needed: bool = (block.timestamp - self.epoch_start_time) > INTERVAL
    assert upkeep_needed, "upkeep not needed"
    assert not self.is_picking_winner, "already picking winner"
    
    if self.total_tickets_in_current_epoch == 0:
        self._start_next_epoch()
        log Raffle__EpochSkipped(epoch_num=self.current_epoch - 1)
        return

    self._request_randomness()


def _request_randomness():
    self.is_picking_winner = True

    callback_gas_limit: uint32 = 500000
    num_words: uint32 = 1
    request_confirmations: uint16 = 3

    extra_args: Bytes[1024] = VRFV2PlusClient.args_to_bytes(VRFV2PlusClient.ExtraArgsV1(native_payment=True))

    request_price: uint256 = staticcall vrf_v2_plus_wrapper.calculateRequestPriceNative(callback_gas_limit, num_words)
    assert self.balance >= request_price, "Raffle cannot afford VRF"

    request_id: uint256 = extcall vrf_v2_plus_wrapper.requestRandomWordsInNative(
        callback_gas_limit,
        request_confirmations,
        num_words,
        extra_args,
        value=request_price
    )

    log Raffle__RandomnessRequested(request_id=request_id)


@external
def rawFulfillRandomWords(request_id: uint256, random_words: DynArray[uint256, 1]):
    # Note: Only vrf_v2_plus_wrapper should call this in a real scenario
    assert msg.sender == vrf_v2_plus_wrapper.address, "only VRF wrapper can fulfill"
    self.is_picking_winner = False
    
    # We use modulo to pick a winner from the tickets sold in this epoch
    winning_ticket_index: uint256 = random_words[0] % self.total_tickets_in_current_epoch
    winner: address = self.tickets[self.current_epoch][winning_ticket_index]
    
    reward: uint256 = self.balance
    
    log Raffle__EpochCompleted(
        epoch_num=self.current_epoch, 
        winner=winner, 
        winning_ticket=winning_ticket_index, 
        reward=reward, 
        num_tickets=self.total_tickets_in_current_epoch
    )

    self._start_next_epoch()
    send(winner, reward)

def _start_next_epoch():
    self.current_epoch += 1
    self.total_tickets_in_current_epoch = 0
    self.epoch_start_time = block.timestamp
    

@external
@view
def get_interval() -> uint256:
    return INTERVAL


@external
@view
def get_max_tickets() -> uint256:
    return MAX_TICKETS


@external
@view
def get_ticket_owner(_epoch: uint256, _ticket_id: uint256) -> address:
    return self.tickets[_epoch][_ticket_id]


@external
@view
def get_vrf_v2_plus_wrapper() -> address:
    return vrf_v2_plus_wrapper.address




    
