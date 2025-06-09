package com.liu.springboot04web.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;

public interface Kn01L003PiesesHasBeenScheMapper {

    public List<Kn01L003ExtraPicesesBean> getPicesesHasBeenScheLsnList(@Param("year") String year, @Param("stuId") String stuId);
    public List<Kn01L003ExtraPicesesBean> getExtraPicesesIntoOneLsnList(@Param("year") String year, @Param("stuId") String stuId);

    // 撤销
    public List<String> getOldLessonIds(String lessonId);
    public int undoLogicalDelLesson(String lessonId);
    public int undoLogicalDelLsfFee(String lessonId);
    public int deletePiesHsbnScheFee(String lessonId);
    public int deletePiesHsbnSche(String lessonId);
    public int deletePiceseExtraIntoOne(String lessonId);

}
