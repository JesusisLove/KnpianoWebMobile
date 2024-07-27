package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn02F003LsnFeeAdvcPayBean;
import com.liu.springboot04web.mapper.Kn02F003LsnFeeAdvcPayMapper;

import java.util.List;

@Repository
public class Kn02F003LsnFeeAdvcPayDao {
    @Autowired
    Kn02F003LsnFeeAdvcPayMapper kn02F003LsnFeeAdvcPayMapper;

    public List<Kn02F003LsnFeeAdvcPayBean> getAdvcFeePayLsnInfo (String stuId, String yearMonth) {

        return kn02F003LsnFeeAdvcPayMapper.getAdvcFeePayLsnInfo(stuId, yearMonth);

    }

}
