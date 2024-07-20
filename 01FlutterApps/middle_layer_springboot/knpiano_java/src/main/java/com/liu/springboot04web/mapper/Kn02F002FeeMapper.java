package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn02F004FeePaid4MobileBean;
public interface Kn02F002FeeMapper  {

    // public List<Kn02F002FeeBean> getInfoList(); // 废弃不要了
    // year不为空的时候不执行where条件
    public List<Kn02F002FeeBean> getInfoList(@Param("year") String year);
    public List<Kn02F002FeeBean> searchLsnFee(@Param("params") Map<String, Object> queryparams);
    public Kn02F002FeeBean       getInfoById(String lsnFeeId, String lessonId);
    public List<Kn02F002FeeBean> checkScheLsnCurrentMonth(@Param("stuId")      String  stuId,
                                                          @Param("subjectId")  String  subjectId, 
                                                          @Param("lessonType") Integer lessonType,
                                                          @Param("lsnMonth")   String  lsnMonth);

    // 手机前端用：从学生课程管理表视图中取得在课学生正在上的科目，在课程费用管理的新规画面实现学生与科目的下拉列表框的联动：科目信息取决于选择的学生
    public List<Kn02F004FeePaid4MobileBean> getStuFeeListByYear(@Param("stuId")String stuId,
                                                     @Param("year") String year);
    public void updateInfo(Kn02F002FeeBean bean);
    // 課費未精算模块里，点击【学費精算】ボタン、精算画面にての【保存】ボタン押下、 own_flgの値を０から１に変更する処理
    public void updateOwnFlg(Kn02F002FeeBean bean);
    public void insertInfo(Kn02F002FeeBean bean);
    public void deleteInfo(String lsnFeeId, String lessonId);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

    // 手机前端课程进度统计页面的上课完了Tab页（统计指定年度中的每一个已经签到完了的课程（已支付/未支付的课程都算）
    public List<Kn02F002FeeBean> getInfoLsnStatisticsByStuId(String stuId, String year);
}
