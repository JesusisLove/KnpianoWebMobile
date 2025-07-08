package com.liu.springboot04web.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F003AdvcLsnPayListBean;

public interface Kn02F003AdvcLsnPayListDao {

    public List<Kn02F003AdvcLsnPayListBean> getAdvcLsnPayStuName(@Param("year") String year);

    public List<Kn02F003AdvcLsnPayListBean> getAdvcLsnPayList(@Param("stuId") String stuId, @Param("year") String year);

}
