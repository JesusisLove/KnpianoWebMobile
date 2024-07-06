package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn01L002LsnMapper;
import com.liu.springboot04web.othercommon.DateUtils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;@Repository

public class Kn01L002LsnDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn01L002LsnMapper knLsn001Mapper;
    @Autowired
    private Kn03D004StuDocDao knStuDoc001Dao;
    @Autowired
    private Kn02F002FeeDao    kn02F002FeeDao;
    @Autowired
    private Kn02F004PayDao    kn02f004PayDao;

    public List<Kn01L002LsnBean> getInfoList() {
        List<Kn01L002LsnBean> list =knLsn001Mapper.getInfoList();
        return list;
    }

    // 手机前端页面课程表页面，获取指定元月日这一天的学生的排课课程
    public List<Kn01L002LsnBean> getInfoListByDay(String schedualDate) {
        List<Kn01L002LsnBean> list =knLsn001Mapper.getInfoListByDay(schedualDate);
        return list;
    }

    // 获取所有符合查询条件的课程信息
    public List<Kn01L002LsnBean> searchLessons(Map<String, Object> params) {
        return knLsn001Mapper.searchLessons(params);
    }

    public Kn01L002LsnBean getInfoById(String id) {
        Kn01L002LsnBean knLsn001Bean = knLsn001Mapper.getInfoById(id);
        return knLsn001Bean;
    }

    public void save(Kn01L002LsnBean knLsn001Bean) {
        if (knLsn001Bean.getLessonId() == null 
        || knLsn001Bean.getLessonId().isEmpty()) { 

            Map<String, Object> map = new HashMap<String, Object> ();
                map.put("parm_in", KNConstant.CONSTANT_KN_LSN_SEQ);
                // 授業自動採番
                knLsn001Mapper.getNextSequence(map);
                knLsn001Bean.setLessonId(KNConstant.CONSTANT_KN_LSN_SEQ + (Integer)map.get("parm_out"));

            // 授業番号の自動採番
            knLsn001Mapper.getNextSequence(map);
            insert(knLsn001Bean);
        } else {
            update(knLsn001Bean);
        }
    }

    // 撤销签到
    public void restoreSignedLsn(String lessonId) {
        knLsn001Mapper.restoreSignedLsn(lessonId);
    }

    // 撤销调课
    public void reScheduleLsnCancel(String lessonId) {
        knLsn001Mapper.reScheduleLsnCancel(lessonId);
    }

    // 新規
    private void insert(Kn01L002LsnBean knLsn001Bean) {
        knLsn001Mapper.insertInfo(knLsn001Bean);
    }

    // 変更，调课
    private void update(Kn01L002LsnBean knLsn001Bean) {
        knLsn001Mapper.updateInfo(knLsn001Bean);
    }

    // 削除
    public void delete(String id) { 
        knLsn001Mapper.deleteInfo(id); 
    }

    // 签到
    @Transactional
    public void excuteSign(Kn01L002LsnBean knLsn001Bean) {
        // 检查该课程是否是有效的课程
        if (checkThisLsn(knLsn001Bean)) {
            // 进行签到登记：对knLsn001Bean里的上课日期执行数据库表的更新操作
            knLsn001Bean.setScanQrDate(new Date());
            save(knLsn001Bean);

            // 对签到的课程执行课费计算 
            addNewLsnFee(knLsn001Bean);
        }
    }

    // 撤销
    @Transactional
    public void excuteUndo(Kn01L002LsnBean knLsn001Bean) {
        // 将签到日期撤销
        knLsn001Bean.setScanQrDate(null);
        restoreSignedLsn(knLsn001Bean.getLessonId());

        // 课费撤销
        undoNewLsnFee(knLsn001Bean);
    }

    /**
     *  过期的科目，签到不可（比如1月上钢琴3级，现在是5月份都已經上4级的钢琴课，3级的课已经不再上了
     *  这个时候，把1月份为签到的课，在5月份执行签到的时候，这个3级的课就是过期的科目），不予执行签到。
     * @param knLsn001Bean
     * @return
     */
    private boolean checkThisLsn(Kn01L002LsnBean knLsn001Bean) {
        // 计算该科目最新的费用
        // Kn03D002StuDocBean stuDocBean = knStuDoc001Dao.getLsnPrice(knLsn001Bean.getStuId(), knLsn001Bean.getSubjectId());
        // TODO

        return true;
    }

    // 签到时，对课费管理表登录该科目的课费
    private void addNewLsnFee(Kn01L002LsnBean knLsn001Bean) {
        // 计算该科目最新的费用
        Kn02F002FeeBean kn02F002FeeBean = setLsnFeeBean(knLsn001Bean);

        // 新规课程费用信息，保存到课费信息表里
        kn02F002FeeDao.save(kn02F002FeeBean);
    }

    private Kn02F002FeeBean setLsnFeeBean(Kn01L002LsnBean knLsn001Bean) {

        Kn03D004StuDocBean stuDocBean = knStuDoc001Dao.getLsnPrice(knLsn001Bean.getStuId(), knLsn001Bean.getSubjectId(), knLsn001Bean.getSubjectSubId());
        Kn02F002FeeBean bean = new Kn02F002FeeBean();
        
        bean.setStuId(knLsn001Bean.getStuId());
        bean.setLessonId(knLsn001Bean.getLessonId());
        // 有调整价格的使用调整价格
        bean.setLsnFee(stuDocBean.getLessonFeeAdjusted() > 0 ? stuDocBean.getLessonFeeAdjusted() : stuDocBean.getLessonFee());
        // 利用计划课取得产生课费的月份
        bean.setLsnMonth(DateUtils.getCurrentDateYearMonth(knLsn001Bean.getSchedualDate()));

        // 课程类型lessonType 0:按课时结算的课程  1:按月结算的课程（计划课）  2:按月结算的课程（加时课）
        bean.setLessonType(knLsn001Bean.getLessonType());
        bean.setSubjectId(knLsn001Bean.getSubjectId());
        bean.setPayStyle(stuDocBean.getPayStyle());
        bean.setOwnFlg(0);

        // 按月精算的课程的own_flg设定处理
        if (bean.getPayStyle() == 1) {
            setOwnFlg(bean);
        }

        return bean;
    }

    /**
     * 检测对象：签到按月结算的科目，
     * 执行条件：该月的计划课时签到未满（一个月4节课或5节课）的情况下，就执行了月精算处理
     *        （也就是说，该月计划课程还没上满4节课（该月有第五周就时5节课）就已经执行了精算处理）
     * 业务场景：签到了1节课，就执行了按月计算处理，这样课费表里只有这一节签到课的ownFlg变更为0了
     * 那么剩下的这3节课，因为是计划课，所以在签到的同时也应当把自身的ownFlg设置为0存到课费金额表里
    */
    private void setOwnFlg (Kn02F002FeeBean bean) {
        List<Kn02F004PayBean> list = kn02f004PayDao.isHasMonthlyPaid(bean.getStuId(), bean.getSubjectId(), bean.getLsnMonth());
        if (list.size() > 0) {
            bean.setOwnFlg(1);
        }

    }

    // 撤销时，对课费管理表登录的该科目的课费执行删除操作
    private void undoNewLsnFee(Kn01L002LsnBean knLsn001Bean) {
        // 从课费管理表取得该课的lsn_fee_id
        Map<String, Object> condition = new HashMap<>();
        condition.put("lesson_id", knLsn001Bean.getLessonId());

        // 此处虽然用的是Kn02F002FeeMapper的模糊查询，因为lesson_id在课费管理表里也是唯一值，所以不会出现多条记录的现象，所以使用该函数没有问题。
        List<Kn02F002FeeBean> searchResults = kn02F002FeeDao.searchLsnFee(condition);
        Kn02F002FeeBean feeBean = searchResults.get(0);

        // 删除当日的课费计算记录
        kn02F002FeeDao.delete(feeBean.getLsnFeeId(), feeBean.getLessonId());
    }
}