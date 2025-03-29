package com.liu.springboot04web.dao;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn01L002ExtraToScheBean;
import com.liu.springboot04web.mapper.Kn01L003ExtraPiesesIntoOneMapper;

@Repository
public class Kn01L003ExtraPiesesIntoOneDao {

    @Autowired
    private Kn01L003ExtraPiesesIntoOneMapper kn01L003ExtraPiesesIntoOneMapper;
    
    public List<Kn01L002ExtraToScheBean> getExtraPiesesLsnList(String year, String stuId) {
        return kn01L003ExtraPiesesIntoOneMapper.getExtraPiesesLsnList(year, stuId);
    }

    public List<Kn01L002ExtraToScheBean> getSearchInfo4Stu(String year) {
        return kn01L003ExtraPiesesIntoOneMapper.getSearchInfo4Stu(year);
    }

    

}
