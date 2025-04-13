package com.liu.springboot04web.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F004PayBean;

public interface KnErrorDataWatchDao {

    public List<Kn01L002LsnBean> getErrLsnDataList(@Param("year") String year);
    public List<Kn01L002LsnBean> getErrLsnGroupDataList();

    public List<Kn02F004PayBean> getErrFeeDataList(); 

}
