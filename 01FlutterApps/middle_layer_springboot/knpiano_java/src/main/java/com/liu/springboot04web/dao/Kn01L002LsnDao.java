package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn02F003LsnFeeAdvcPayBean;
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

public class Kn01L002LsnDao {

    @Autowired
    private Kn01L002LsnMapper knLsn001Mapper;
    @Autowired
    private Kn03D004StuDocDao knStuDoc001Dao;
    @Autowired
    private Kn02F002FeeDao    kn02F002FeeDao;
    @Autowired
    private Kn02F004PayDao    kn02f004PayDao;
    @Autowired
    Kn02F003LsnFeeAdvcPayDao  kn02F003LsnFeeAdvcPayDao;

    public List<Kn01L002LsnBean> getInfoList(String year) {
        List<Kn01L002LsnBean> list =knLsn001Mapper.getInfoList(year);
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

    // 执行签到
    @Transactional
    public void excuteSign(Kn01L002LsnBean knLsn001Bean) {
        // 检查该课程是否是有效的课程
        if (checkThisLsn(knLsn001Bean)) {
            // 进行签到登记：对knLsn001Bean里的上课日期执行数据库表的更新操作
            knLsn001Bean.setScanQrDate(new Date());
            save(knLsn001Bean);

            // 如果课费预支付表里已经有了该课的预支付记录，就表示不必再往课费表里进行插入操作，否则会发生主键冲突
            String lessonId = knLsn001Bean.getLessonId();
            Kn02F003LsnFeeAdvcPayBean advcPaidBean = 
                        kn02F003LsnFeeAdvcPayDao.getAdvcFeePaidyInfoByIds(lessonId, null, null);
            if (knLsn001Bean.getLessonType() == 1 && advcPaidBean != null) {
                // 对课费预支付表里的该当lesson_id的advc_flg值做更新操作（advc_flg值，从0更新为1）
                advcPaidBean.setAdvcFlg(1);
                kn02F003LsnFeeAdvcPayDao.update(advcPaidBean);

                // 对课程表不做任何操作（月计划课程在课费预支付表里存在的话，不能再往课费表里执行插入操作）。
                // 重复的lesson_id会导致主键冲突的数据库错误。
            } else {
                // 对签到的课程执行课费计算 
                addNewLsnFee(knLsn001Bean);
            }
        }
    }

    // 撤销签到
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
        // 计划课还分为月计划:(lessonType=1)，和月加课:(lessonType=2)，这里处理的对象是月计划。月加课的费用另结算
        if (bean.getPayStyle() == 1 && bean.getLessonType() == 1) {
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

        // 如果课费预支付表里已经有了该课的预支付记录，就表示不必再往课费表里进行插入操作，否则会发生主键冲突
        String lessonId = knLsn001Bean.getLessonId();
        Kn02F003LsnFeeAdvcPayBean advcPaidBean = 
                    kn02F003LsnFeeAdvcPayDao.getAdvcFeePaidyInfoByIds(lessonId, null, null);
        if (knLsn001Bean.getLessonType() == 1 && advcPaidBean != null) {
            // 对课费预支付表里的该当lesson_id的advc_flg值做更新操作（advc_flg值，从1还原为0）
            advcPaidBean.setAdvcFlg(0);
            kn02F003LsnFeeAdvcPayDao.update(advcPaidBean);

            // 因为课费预支付操作就有了《课程表》与《课费表》直接有外建约束的数据完整性，，此处不能执行课费表的删除操作。
            // 对《课费表》当日的课费记录不做删除处理
        } else {
            // 对《课费表》当日的课费记录做删除处理
            kn02F002FeeDao.delete(feeBean.getLsnFeeId(), feeBean.getLessonId());
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

    // 新規排课
    private void insert(Kn01L002LsnBean knLsn001Bean) {
        knLsn001Mapper.insertInfo(knLsn001Bean);
    }

    // 修改排课
    private void update(Kn01L002LsnBean knLsn001Bean) {
        knLsn001Mapper.updateInfo(knLsn001Bean);
    }

    // 削除排课
    public void delete(String id) { 
        knLsn001Mapper.deleteInfo(id); 
    }

    // 手机前端：课程进度统计--【还未上课统计】Tab，提取未上课（未签到）的 处理
    public List<Kn01L002LsnBean> getUnScanSQDateLsnInfoByYear(String stuId, String year) {
        return knLsn001Mapper.getUnScanSQDateLsnInfoByYear(stuId, year);                                                          
    }
}