package com.liu.springboot04web.mapper;

import java.util.List;

import javax.websocket.server.PathParam;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn01L002ExtraToScheBean;

public interface Kn01L003ExtraPiesesIntoOneMapper {
    public List<Kn01L002ExtraToScheBean> getExtraPiesesLsnList(@Param("year") String year, @Param("stuId") String stuId);
    public List<Kn01L002ExtraToScheBean> getSearchInfo4Stu(@PathParam("pieceExtraYear") String year);

}
