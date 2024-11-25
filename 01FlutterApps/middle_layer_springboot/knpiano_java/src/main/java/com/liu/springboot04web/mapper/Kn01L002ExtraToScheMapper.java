package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn01L002ExtraToScheBean;
import com.liu.springboot04web.bean.Kn02F002FeeBean;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

public interface Kn01L002ExtraToScheMapper {

        public List<Kn01L002ExtraToScheBean> getInfoListExtraCanBeSche(@Param("year") String year);

        public List<Kn01L002ExtraToScheBean> getInfoListExtraCanBeSche(@Param("stuId") String stuId, @Param("year") String year);

        List<Kn01L002ExtraToScheBean> searchUnpaidExtraLessons(@Param("params") Map<String, Object> queryparams);

        public Kn01L002ExtraToScheBean getInfoListExtraCanBeScheDetail(@Param("lessonId") String lessonId);

        // 将原加课产生的课费“废除”
        // public void updateLsnFeeFlg (String lessonId, int delFlg);
        public void updateLsnFeeFlg (String lessonId, float lsnFee, int delFlg);

        // 取得要换正课前的lsn_fee_id，取得条件：课程Id（lessonId)
        // public String getOldLessonIdInfo(String lessonId);
        public Kn02F002FeeBean getOldLessonIdInfo(String lessonId);

        // 取得要换正课后的lsn_fee_id，取得条件：换正课的月份
        public List<String> getNewLessonIdInfo(String stuId, String lsnMonth, int lessonType);

        // 执行加课换正课的信息保存
        public void insertExtraToScheInfo(String lessonId, String oldLsnFeeId, String newLsnFeeId, Date newScanQrDate, float lsnFee, int isGoodChange);

        // 课程表里的课程记录，还原为原来的月加课状态 
        public void updateExtraDateIsNull(String lessonId);

        // 执行撤销的时候，取得当前lessonId的加课换正课记录
        public  Kn01L002ExtraToScheBean getExtraToScheInfo(String lessonId);

        // 删除加课换正课中间表记录
        public void deleteOldNewLsnFeeId(String lessonId);

}