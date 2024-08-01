package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F003LsnFeeAdvcPayBean;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface Kn02F003LsnFeeAdvcPayMapper {

    public List<Kn02F003LsnFeeAdvcPayBean> getAdvcFeePayLsnInfo(@Param("stuId") String stuId,
                                                                @Param("yearMonth") String yearMonth);

    public List<Kn02F003LsnFeeAdvcPayBean> getAdvcFeePaidInfoByCondition(@Param("stuId") String stuId,
                                                                         @Param("yearMonth") String yearMonth);
                                                                         
    void executeAdvcLsnFeePay(
        @Param("stuId") String stuId,
        @Param("subjectId") String subjectId,
        @Param("subjectSubId") String subjectSubId,
        @Param("lessonType") Integer lessonType,
        @Param("schedualType") Integer schedualType,
        @Param("minutesPerLsn") Integer minutesPerLsn,
        @Param("subjectPrice") float subjectPrice,
        @Param("schedualDate") Date schedualDate,
        @Param("bankId") String bankId,
        @Param("lsnSeqCode") String lsnSeqCode,
        @Param("feeSeqCode") String feeSeqCode,
        @Param("paySeqCode") String paySeqCode,
        @Param("paramMap") Map<String, Object> paramMap
    );
}