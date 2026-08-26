/// @desc Machine à états du round

switch (round_state)
{
    case "active":
        break;

    case "round_end":
        round_end_timer--;
        if (round_end_timer <= 0)
        {
            round_state = "respawning";
            respawn_all_players();
        }
        break;

    case "respawning":
        round_state = "active";
        round_number++;
        break;
}