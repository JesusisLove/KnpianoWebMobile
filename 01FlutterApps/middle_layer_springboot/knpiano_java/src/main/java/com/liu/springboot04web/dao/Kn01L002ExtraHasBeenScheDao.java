package com.liu.springboot04web.dao;

import java.util.List;

import com.liu.springboot04web.bean.Kn01L002ExtraHasBeenScheBean;

public interface Kn01L002ExtraHasBeenScheDao {

    public List<Kn01L002ExtraHasBeenScheBean> getSearchInfo4Stu(String year);
    public List<Kn01L002ExtraHasBeenScheBean> getExcrHasBeenScheInfo(String stuId, String year, Integer isGoodChange);

}
