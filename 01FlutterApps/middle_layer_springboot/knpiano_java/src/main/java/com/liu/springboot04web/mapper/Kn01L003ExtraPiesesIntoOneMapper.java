package com.liu.springboot04web.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;

public interface Kn01L003ExtraPiesesIntoOneMapper {

    // WEB页面用
    public List<Kn01L003ExtraPicesesBean> getExtraPiesesLsnList(@Param("year") String year, @Param("stuId") String stuId);
    // WEB页面用
    public List<Kn01L003ExtraPicesesBean> getSearchInfo4Stu(@Param("pieceExtraYear") String year);
    // 手机前端设备用
    public List<Kn03D004StuDocBean> getStuName4Mobile(@Param("pieceExtraYear") String year);
    // 手机前端设备用
   public List<Kn03D004StuDocBean> getLatestLsnPriceInfo4Mobile(@Param("pieceExtraYear") String year, @Param("stuId") String stuId);
    // 执行拼成的整课转换成正课（计划课）
    public int savePiceseExtraIntoOne(String lessonId, String oldLessonId);
    public int logicalDelLesson(String lessonId);
    public int logicalDelLsfFee(String lessonId);

}
