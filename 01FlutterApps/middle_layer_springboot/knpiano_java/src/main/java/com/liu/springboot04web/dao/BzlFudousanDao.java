package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.BzlFudousanBean;

import java.util.List;

public interface BzlFudousanDao {

    public List<?> getInfoList();
    public BzlFudousanBean getInfoById(String id);
//    public void save (Class<?> cls);
    public void delete(String id);

}
