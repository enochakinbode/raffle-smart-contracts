import boa
from tests.units.conftest import fresh_raffle


def test_check_upkeep():
    with fresh_raffle() as raffle:
        upkeep_needed_before, return_data_before = raffle.checkUpkeep(b"\x00" * 32)
        assert (
            upkeep_needed_before == False
        ), "Upkeep should not be needed before interval expires"
        assert return_data_before == b"\x00"

        boa.env.time_travel(seconds=301)
        upkeep_needed_after, return_data_after = raffle.checkUpkeep(b"\x00" * 32)
        assert upkeep_needed_after == True, "Upkeep should be needed"
        assert return_data_after == b"\x00"


def test_perform_upkeep_epoch_skip():
    with fresh_raffle() as raffle:
        with boa.reverts("upkeep not needed"):
            raffle.performUpkeep(b"\x00" * 32)

        upkeep_needed_before, return_data_before = raffle.checkUpkeep(b"\x00" * 32)
        assert (
            upkeep_needed_before == False
        ), "Upkeep should not be needed before interval expires"
        assert return_data_before == b"\x00"

        # Advance time past interval
        boa.env.time_travel(seconds=301)

        # Check what checkUpkeep returns after interval expires
        upkeep_needed_after, return_data_after = raffle.checkUpkeep(b"\x00" * 32)
        assert (
            upkeep_needed_after == True
        ), "Upkeep should be needed after interval expires"
        assert return_data_after == b"\x00"

        # Now performUpkeep should work - get the transaction/computation
        tx = raffle.performUpkeep(b"\x00" * 32)

        # Get logs from the transaction
        logs = raffle.get_logs(tx)

        # Check that Raffle__EpochSkipped event was emitted
        assert len(logs) > 0, "Should have at least one log"
        # Find the Raffle__EpochSkipped event
        epoch_skipped_log = None
        for log in logs:
            if hasattr(log, "epoch_num") and log.epoch_num == 0:
                epoch_skipped_log = log
                break

        assert (
            epoch_skipped_log is not None
        ), "Raffle__EpochSkipped event should be emitted"
        assert epoch_skipped_log.epoch_num == 0, "Epoch number should be 0"
