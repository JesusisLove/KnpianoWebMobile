package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnPianoBean;

import java.util.List;

public interface InterfaceKnPianoDao {

    public List<?> getInfoList();
    public KnPianoBean getInfoById(String id);
    // public void save (Class<?> cls);
    // public void delete(String id);

}
