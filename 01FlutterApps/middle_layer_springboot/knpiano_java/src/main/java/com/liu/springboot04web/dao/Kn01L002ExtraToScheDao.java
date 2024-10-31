package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn01L002ExtraToScheBean;
import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn01L002ExtraToScheMapper;
import com.liu.springboot04web.mapper.Kn01L002LsnMapper;
import com.liu.springboot04web.mapper.Kn02F002FeeMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class Kn01L002ExtraToScheDao {

    @Autowired
    private Kn01L002ExtraToScheMapper kn01l002ExtraToScheMapper;

    @Autowired
    private Kn01L002LsnMapper kn01L002LsnMapper;

    @Autowired(required=false)
    private Kn01L002LsnBean knLsn001Bean;

    @Autowired
    private Kn02F002FeeMapper knLsnFee001Mapper;

    @Autowired
    private TInfoLessonExtraToScheBean tblBean;

    @Autowired(required=false)
    private Kn02F002FeeBean feeBean;



    public List<Kn01L002ExtraToScheBean> getInfoList(String year) {
        List<Kn01L002ExtraToScheBean> list = kn01l002ExtraToScheMapper.getInfoListExtraCanBeSche(year);
        return list;
    }

    // 获取所有符合查询条件的课程信息
    public List<Kn01L002ExtraToScheBean> searchLessons(Map<String, Object> params) {
        return kn01l002ExtraToScheMapper.searchUnpaidExtraLessons(params);
    }

    // 根据lessonId提取要换正课的加课明细
    public Kn01L002ExtraToScheBean getExtraLsnDetail(String lessonId) {
        return kn01l002ExtraToScheMapper.getInfoListExtraCanBeScheDetail(lessonId);
    }

    // 执行加课换正课处理
    /* 采用事务处理机制 */ 
    @Transactional
    public void executeExtraToSche(Kn01L002ExtraToScheBean kn01L002ExtraToScheBean) {
        // 从画面传过来的lessonId退避到变量中
        String lessonId = kn01L002ExtraToScheBean.getLessonId();

        // ①取得要换正课前的lsn_fee_id，取得条件：lessonId
        String oldLsnFeeId = kn01l002ExtraToScheMapper.getOldLessonIdInfo(lessonId);

        // ②更新课程表的授業変換日付(extra_to_dur_date)，更新条件：lesson_id
        knLsn001Bean = new Kn01L002LsnBean();
        knLsn001Bean.setLessonId(lessonId);
        knLsn001Bean.setExtraToDurDate(kn01L002ExtraToScheBean.getExtraToDurDate());
        kn01L002LsnMapper.updateInfo(knLsn001Bean);

        // ③将原加课产生的课费“废除”:更新t_info_lesson_fee表里的del_flg=1,更新条件：课程Id（lessonId)
        kn01l002ExtraToScheMapper.updateLsnFeeFlg(lessonId,1);
        
        // ④取得要换正课后的lsn_fee_id，取得条件：换正课的月份
        // getExtraToDurDate：是从前段页面传过来的换正课日期
        String targetLsnMonth = new java.text.SimpleDateFormat("yyyy-MM-dd")
                                        .format(kn01L002ExtraToScheBean.getExtraToDurDate())
                                        .substring(0, 7);
        feeBean = kn01l002ExtraToScheMapper.getNewLessonIdInfo(targetLsnMonth);

        // ⑤加课换正课情報作成
        // ⑤-1:oldLsnFeeId的设置
        tblBean.setLessonId(lessonId);tblBean.setOldLsnFeeId(oldLsnFeeId);tblBean.setLessonId(lessonId);
        // ⑤-2:newLsnFeeId的设置
        if (feeBean == null) {
            // lsn_fee_idを採番
            Map<String, Object> map = new HashMap<>();
                map.put("parm_in", KNConstant.CONSTANT_KN_LSN_FEE_SEQ);
                // 课程费用的自動採番:採番番号 = new_lsn_fee_id = origin_lsn_fee_id 
                knLsnFee001Mapper.getNextSequence(map);
                String newLsnFeeId = KNConstant.CONSTANT_KN_LSN_FEE_SEQ + (Integer)map.get("parm_out");
                tblBean.setNewLsnFeeId(newLsnFeeId);

        } else {
            // 设置换正课后的lsn_fee_id
            tblBean.setNewLsnFeeId(feeBean.getLsnFeeId());
        }

        // ⑥执行保存加课换正课的处理（其实处理的是课费的结算，即原来准备按加课费收费，由于换成其他月份的正课，就不在当前月收取加课费了）
        kn01l002ExtraToScheMapper.insertExtraToScheInfo(tblBean.getLessonId(),tblBean.getOldLsnFeeId(),tblBean.getNewLsnFeeId());
    }

    // 撤销加课换正课处理
    /* 采用事务处理机制 */ 
    @Transactional
    public void undoExtraToSche(String lessonId) {

        // ①将课程表的加课换正课日期赋值为null，更新条件：lessonId
        kn01l002ExtraToScheMapper.updateExtraDateIsNull(lessonId);

        // ②将课费表的del_flg值还原为0，更新条件：lessonId
        kn01l002ExtraToScheMapper.updateLsnFeeFlg(lessonId,0);

        // ③删除加课换正课中间表的记录，删除条件：lessonId
        kn01l002ExtraToScheMapper.deleteOldNewLsnFeeId(lessonId);
    }
}


/**
 * 加课换正课情報作成
 * 数据库t_info_lesson_extra_to_sche表的Bean类
*/ 
@Repository
class TInfoLessonExtraToScheBean {

    // 课程ID
    String lessonId;

    // 换正课之后的课费ID
    String newLsnFeeId;

    // 换正课之前的课费ID
    String oldLsnFeeId;

    public String getLessonId() {
        return lessonId;
    }

    public void setLessonId(String lessonId) {
        this.lessonId = lessonId;
    }

    public String getNewLsnFeeId() {
        return newLsnFeeId;
    }

    public void setNewLsnFeeId(String newLsnFeeId) {
        this.newLsnFeeId = newLsnFeeId;
    }

    public String getOldLsnFeeId() {
        return oldLsnFeeId;
    }

    public void setOldLsnFeeId(String oldLsnFeeId) {
        this.oldLsnFeeId = oldLsnFeeId;
    }
}