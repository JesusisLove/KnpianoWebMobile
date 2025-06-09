package com.liu.springboot04web.mapper;

import java.util.List;
import javax.websocket.server.PathParam;
import org.apache.ibatis.annotations.Param;
import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;

public interface Kn01L003ExtraPiesesIntoOneMapper {

    public List<Kn01L003ExtraPicesesBean> getExtraPiesesLsnList(@Param("year") String year, @Param("stuId") String stuId);
    public List<Kn01L003ExtraPicesesBean> getSearchInfo4Stu(@PathParam("pieceExtraYear") String year);
    public int savePiceseExtraIntoOne(String lessonId, String oldLessonId);
    public int logicalDelLesson(String lessonId);
    public int logicalDelLsfFee(String lessonId);

}
