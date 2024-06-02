package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn03D002StuDocBean;
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
    private Kn03D002StuDocDao knStuDoc001Dao;
    @Autowired
    private Kn02F002FeeDao    kn02F002FeeDao;

    public List<Kn01L002LsnBean> getInfoList() {
    List<Kn01L002LsnBean> list =knLsn001Mapper.getInfoList();
    // System.out.println("selectの学生授業情報管理データ：" + list.toString());
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

    // 新規
    private void insert(Kn01L002LsnBean knLsn001Bean) {
        knLsn001Mapper.insertInfo(knLsn001Bean);
    }

    // 変更
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
        save(knLsn001Bean);

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
        Kn03D002StuDocBean stuDocBean = knStuDoc001Dao.getLsnPrice(knLsn001Bean.getStuId(), knLsn001Bean.getSubjectId());

        Kn02F002FeeBean kn02F002FeeBean = new Kn02F002FeeBean();
        kn02F002FeeBean.setStuId(knLsn001Bean.getStuId());
        kn02F002FeeBean.setLessonId(knLsn001Bean.getLessonId());
        // 有调整价格的使用调整价格
        kn02F002FeeBean.setLsnFee(stuDocBean.getLessonFeeAdjusted() > 0 ? 
                                  stuDocBean.getLessonFeeAdjusted() : stuDocBean.getLessonFee());
        // 利用计划课取得产生课费的月份
        kn02F002FeeBean.setLsnMonth(DateUtils.getCurrentDateYearMonth(knLsn001Bean.getSchedualDate()));

        // 课程类型lessonType 0:按课时结算的课程  1:按月结算的课程（计划课）  2:按月结算的课程（加时课）
        kn02F002FeeBean.setLessonType(knLsn001Bean.getLessonType());
        kn02F002FeeBean.setSubjectId(knLsn001Bean.getSubjectId());
        kn02F002FeeBean.setPayStyle(stuDocBean.getPayStyle());

        // 新规课程费用信息，保存到课费信息表里
        kn02F002FeeDao.save(kn02F002FeeBean);
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