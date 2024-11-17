package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.mapper.Kn02F002FeeMapper;
import com.liu.springboot04web.mapper.Kn02F004PayMapper;
import java.util.List;
import java.util.Map;

@Repository
public class Kn02F004PayDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn02F004PayMapper knLsnPay001Mapper;
    @Autowired
    private Kn02F002FeeMapper kn02F002FeeMapper;
    @Autowired
    private Kn02F002FeeDao kn02F002FeeDao;

    // 画面初期化显示所科目信息
    public List<Kn02F004PayBean> getInfoList() {
        List<Kn02F004PayBean> list =knLsnPay001Mapper.getInfoList();
        return list;
    }

    // 获取所有符合查询条件的支付信息
    public List<Kn02F004PayBean> searchLsnPay(Map<String, Object> params) {
        return knLsnPay001Mapper.searchLsnPay(params);
    }

    // 在课程管理模块里，当执行“签到”时，查看按月付费的科目有没有已经执行了月费结算处理
    // （抽出的记录0件以上就表示该月计划课程还没上满就已经执行了精算处理）
    public List<Kn02F004PayBean> isHasMonthlyPaid(String stuId, String subjectId, String payMonth) {
        return knLsnPay001Mapper.isHasMonthlyPaid(stuId, subjectId, payMonth);
    }

    // 根据ID获取课费支付信息
    public Kn02F004PayBean getInfoById(String id) {
        return null;
    }

    // 撤销支付课费
    public void excuteUndoLsnPay(String lsnPayId, String lsnFeeId, String payMonth) { 
        // 《结算表》撤销课费结算
        knLsnPay001Mapper.deleteInfo(lsnPayId, lsnFeeId); 

        // 《课费表》对结算标识own_flg字段做1→0的更新操作
        Kn02F002FeeBean kn02F002FeeBean = new Kn02F002FeeBean();
        kn02F002FeeBean.setLsnFeeId(lsnFeeId);
        kn02F002FeeBean.setOwnFlg(0);
        kn02F002FeeDao.updateOwnFlg(kn02F002FeeBean);

        // 《加课换正课中间表》对换正课的结算标识own_flg字段做1→0的更新操作
        /* 考虑到加课换正课的情况下，对该课程在《课费表里》显示一支付还是为支付的处理 */
        // 加课换正课的一支付/未支付的状态，在加课换正课中间表里体现：new_own_flg ０→１
        kn02F002FeeMapper.updateNewOwnFlg(lsnFeeId, payMonth, 0);
    }
}
