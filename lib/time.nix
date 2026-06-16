_: {
  time = rec {
    # Divisions of a millisecond.
    ms_per_s = 1000;
    ms_per_min = 60 * ms_per_s;
    ms_per_hour = 60 * ms_per_min;
    ms_per_day = 24 * ms_per_hour;
    ms_per_week = 7 * ms_per_day;

    # Divisions of a second.
    s_per_min = 60;
    s_per_hour = s_per_min * 60;
    s_per_day = s_per_hour * 24;
    s_per_week = s_per_day * 7;
  };
}
