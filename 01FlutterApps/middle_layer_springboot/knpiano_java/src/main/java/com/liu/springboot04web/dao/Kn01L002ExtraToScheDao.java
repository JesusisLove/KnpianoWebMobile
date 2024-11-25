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

import java.util.Date;
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

    private TInfoLessonExtraToScheBean tblBean = new TInfoLessonExtraToScheBean();

    // Web页面后段维护
    public List<Kn01L002ExtraToScheBean> getInfoList(String year) {
        List<Kn01L002ExtraToScheBean> list = kn01l002ExtraToScheMapper.getInfoListExtraCanBeSche(year);
        return list;
    }

    // 手机前端页面
    public List<Kn01L002ExtraToScheBean> getInfoList(String stuId, String year) {
        List<Kn01L002ExtraToScheBean> list = kn01l002ExtraToScheMapper.getInfoListExtraCanBeSche(stuId, year);
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

        // ①取得该加课换正课前的lsn_fee_id和加课的课费，取得条件：lessonId
        Kn02F002FeeBean feeBean = kn01l002ExtraToScheMapper.getOldLessonIdInfo(lessonId);
        String oldLsnFeeId = feeBean.getLsnFeeId();
        float lsnFee = feeBean.getLsnFee();

        // ②更新课程表的授業変換日付(extra_to_dur_date)，更新条件：lesson_id
        knLsn001Bean = new Kn01L002LsnBean();
        knLsn001Bean.setLessonId(lessonId);
        knLsn001Bean.setExtraToDurDate(kn01L002ExtraToScheBean.getExtraToDurDate());
        kn01L002LsnMapper.updateInfo(knLsn001Bean);

        // ③取得要换正课后的lsn_fee_id，取得条件：换正课的月份
        // getExtraToDurDate：是从前段页面传过来的换正课日期
        String targetLsnMonth = new java.text.SimpleDateFormat("yyyy-MM-dd")
                                        .format(kn01L002ExtraToScheBean.getExtraToDurDate())
                                        .substring(0, 7);
        String studentId = kn01L002ExtraToScheBean.getStuId();

        List<String> newLsnFeeIdLst = kn01l002ExtraToScheMapper.getNewLessonIdInfo(studentId, targetLsnMonth, 1);

        // ④加课换正课情報作成
        // ④-1:oldLsnFeeId的设置
        tblBean.setLessonId(lessonId);tblBean.setOldLsnFeeId(oldLsnFeeId);
        tblBean.setNewScanQrDate(kn01L002ExtraToScheBean.getExtraToDurDate());
        tblBean.setLsnFee(lsnFee); // 记录换正课之前的加课课费
        // ④-2:newLsnFeeId的设置
        int delFlg = 1 ;

        // 换正课的lsn_fee_id採番（换正课所在月没有既存记录）
        if (newLsnFeeIdLst == null || newLsnFeeIdLst.size() == 0) {
            Map<String, Object> map = new HashMap<>();
                map.put("parm_in", KNConstant.CONSTANT_KN_LSN_FEE_SEQ);
                // 课程费用的自動採番:採番番号 = new_lsn_fee_id = origin_lsn_fee_id 
                knLsnFee001Mapper.getNextSequence(map);
                String newLsnFeeId = KNConstant.CONSTANT_KN_LSN_FEE_SEQ + (Integer)map.get("parm_out");
                tblBean.setNewLsnFeeId(newLsnFeeId); 
                // 加课换正课中间表字段设置
                tblBean.setIsGoodChange(1);// 设置【有意义的换课】标识
        } 
        // 换正课所在月的既存lsn_fee_id（换正课所在月有既存记录）
        else {
            String newLsnFeeId = newLsnFeeIdLst.get(0);
            /*  newLsnFeeIdLst里的数组元素个数就是换正课的月份已经上完了的月计划的课数，
            如果数组元素小于4，就表示该加课往这个月份上去换的正课是有效率的正课，它参与课费结算
            如果数组元素大等于4，就表示这个正课白换了，因为超过4节之后的课费都不参与课费结算 */

            // 如果数组元素个数大于等于4，更新课费表（t_info_lesson_fee）表
            // 更新字段：lsn_fee, del_flg
            // 更新值：lsn_fee = 0.0, del_flg = 1
            // 更新条件：lesson_id
            if (newLsnFeeIdLst.size() >= 4) {
                // 课费表字段值设置
                lsnFee = 0;

                // 加课换正课中间表字段设置
                tblBean.setIsGoodChange(0);// 设置【无意义的换课】标识
            } 
            // 如果数组元素个数小于4，更新课费表（t_info_lesson_fee）表
            // 更新字段：del_flg
            // 更新值：del_flg = 1
            // 更新条件：lesson_id
            else {
                
                // 课费的设置处理なし

                // 加课换正课中间表字段设置
                tblBean.setIsGoodChange(1);// 设置【有意义的换课】标识
            }
            // 设置换正课后的lsn_fee_id
            tblBean.setNewLsnFeeId(newLsnFeeId);
        }

        // ⑤将原加课产生的课费“废除”:更新t_info_lesson_fee表里的del_flg=1,更新条件：课程Id（lessonId)
        kn01l002ExtraToScheMapper.updateLsnFeeFlg(lessonId, lsnFee, delFlg);
        // ⑥执行保存加课换正课的处理（其实处理的是课费的结算，即原来准备按加课费收费，由于换成其他月份的正课，就不在当前月收取加课费了）
        kn01l002ExtraToScheMapper.insertExtraToScheInfo(tblBean.getLessonId(),
                                                        tblBean.getOldLsnFeeId(),
                                                        tblBean.getNewLsnFeeId(),
                                                        tblBean.getNewScanQrDate(),
                                                        tblBean.getLsnFee(),
                                                        tblBean.getIsGoodChange());
    }

    // 撤销加课换正课处理
    /* 采用事务处理机制 */ 
    @Transactional
    public void undoExtraToSche(String lessonId) {

        // ①将《课程表》的加课换正课日期赋值为null，更新条件：lessonId
        kn01l002ExtraToScheMapper.updateExtraDateIsNull(lessonId);

        // ②从《加课换正课中间表》中取得原来的课费（lsn_fee）
        Kn01L002ExtraToScheBean bean = kn01l002ExtraToScheMapper.getExtraToScheInfo(lessonId);
        // 将《课费表》的del_flg值还原为0.更新条件：lessonId
        kn01l002ExtraToScheMapper.updateLsnFeeFlg(lessonId, bean.getLsnFee(), 0);

        // ③删除《加课换正课中间表》的记录，删除条件：lessonId
        kn01l002ExtraToScheMapper.deleteOldNewLsnFeeId(lessonId);
    }
}


/**
 * 加课换正课情報作成
 * 数据库t_info_lesson_extra_to_sche表的Bean类
*/ 
class TInfoLessonExtraToScheBean {

    // 课程ID
    String lessonId;

    // 换正课之后的课费ID
    String newLsnFeeId;

    // 换正课之前的课费ID
    String oldLsnFeeId;

    // 加课时的课费
    float lsnFee;

    // @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+9") // 采用东京标准时区，接受手机前端的请求时接纳前端String类型的日期值
    // @DateTimeFormat(pattern = "yyyy-MM-dd")
    protected Date newScanQrDate;

    /**
     *  1:有效率的加课换正课，换正课月份的计划课时不足4节课，加课能有效顶替正课，视为很有效率的加课换正课。
     *  0:没有效率的加课换正课，换正课月份的计划课时已经够4节课了，在换正课就相当于白白浪费了一节加课课时，视为无效率的加课换正课。
     * */
    int isGoodChange;

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

    public float getLsnFee() {
        return lsnFee;
    }

    public void setLsnFee(float lsnFee) {
        this.lsnFee = lsnFee;
    }

    public Date getNewScanQrDate() {
        return newScanQrDate;
    }

    public void setNewScanQrDate(Date newScanQrDate) {
        this.newScanQrDate = newScanQrDate;
    }

    public int getIsGoodChange() {
        return isGoodChange;
    }

    public void setIsGoodChange(int isGoodChange) {
        this.isGoodChange = isGoodChange;
    }
}