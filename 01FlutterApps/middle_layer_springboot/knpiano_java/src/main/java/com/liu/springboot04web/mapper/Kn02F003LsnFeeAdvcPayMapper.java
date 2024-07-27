package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F003LsnFeeAdvcPayBean;

import java.util.List;



public interface Kn02F003LsnFeeAdvcPayMapper {

    public List<Kn02F003LsnFeeAdvcPayBean> getAdvcFeePayLsnInfo(@Param("stuId") String stuId,
                                                                @Param("yearMonth") String yearMonth);

}
