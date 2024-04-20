package com.liu.springboot04web.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class LsnDurationService {
    @Value("${lesson_durations}")
    private List<String> durations;

    @Value("${set_durations}")
    private List<String> minutesPerLsn;

    public List<String> getDurations() {
        return durations;
    }
    public List<String> getMinutesPerLsn() {
        return minutesPerLsn;
    }
}
