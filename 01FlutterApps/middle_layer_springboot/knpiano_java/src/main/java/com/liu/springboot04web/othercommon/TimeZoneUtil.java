package com.liu.springboot04web.othercommon;

import java.time.ZoneId;

public class TimeZoneUtil {
    public static final ZoneId SYSTEM_ZONE = ZoneId.systemDefault();
    public static final String SYSTEM_ZONE_ID = SYSTEM_ZONE.getId();

}
