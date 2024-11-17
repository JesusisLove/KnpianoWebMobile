package com.liu.springboot04web.dao;

import com.liu.springboot04web.constant.KNConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn02F004UnpaidBean;
import com.liu.springboot04web.mapper.Kn02F002FeeMapper;
import com.liu.springboot04web.mapper.Kn02F004UnpaidMapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class Kn02F004UnpaidDao {

    @Autowired
    private Kn02F004UnpaidMapper knLsnUnpaid001Mapper;

    @Autowired
    private Kn02F002FeeMapper kn02F002FeeMapper;

    @Autowired
    Kn02F002FeeDao kn02F002FeeDao;

    // 获取所有符合查询条件的支付信息
    public List<Kn02F004UnpaidBean> searchLsnUnpay(Map<String, Object> params) {
        return knLsnUnpaid001Mapper.searchLsnUnpay(params);
    }

    // 根据课费编号（lsn_fee_id)取得当个未支付信息
    public Kn02F004UnpaidBean getLsnUnpayByID(String lsnFeeId) {
        Kn02F004UnpaidBean knLsnUnpaid001Bean = knLsnUnpaid001Mapper.getLsnUnpayByID(lsnFeeId);
        return knLsnUnpaid001Bean;
    }
    
    // 根据ID获取课费支付信息
    public Kn02F004UnpaidBean getInfoById(String id) {
        return null;
    }

    // 課費精算処理
    public void excuteLsnPay(Kn02F004UnpaidBean knLsnUnPaid001Bean) {
        // 课费支付处理
        save(knLsnUnPaid001Bean);

        // 课费支付信息处理完之后，回头把课费表里相应的课费ID的结算区分，即为支付状态更改为支付完了状态：own_flg ０→１
        Kn02F002FeeBean kn02F002FeeBean = new Kn02F002FeeBean();
        kn02F002FeeBean.setLsnFeeId(knLsnUnPaid001Bean.getLsnFeeId());
        kn02F002FeeBean.setOwnFlg(1);
        kn02F002FeeDao.updateOwnFlg(kn02F002FeeBean);

        /* 考虑到加课换正课的情况下，对该课程在《课费表里》显示一支付还是为支付的处理 */
        // 加课换正课的一支付/未支付的状态，在加课换正课中间表里体现：new_own_flg ０→１
        kn02F002FeeMapper.updateNewOwnFlg(knLsnUnPaid001Bean.getLsnFeeId(), knLsnUnPaid001Bean.getPayMonth(), 1);

    }

    // 課費精算処理
    public void save(Kn02F004UnpaidBean knLsnUnpaid001Bean) {
        if (knLsnUnpaid001Bean.getLsnPayId() == null || knLsnUnpaid001Bean.getLsnPayId().isEmpty()) { 
        
            Map<String, Object> map = new HashMap<>();
            map.put("parm_in", KNConstant.CONSTANT_KN_LSN_PAY_SEQ);
            // 授業課費番号の自動採番
            knLsnUnpaid001Mapper.getNextSequence(map);
            knLsnUnpaid001Bean.setLsnPayId(KNConstant.CONSTANT_KN_LSN_PAY_SEQ + (Integer)map.get("parm_out"));

            insert(knLsnUnpaid001Bean);
        } else {
            // 根据课费ID和课费ID更新《课费表》的支付信息
            update(knLsnUnpaid001Bean);
        }
    }

    // 新規支付课费
    private void insert(Kn02F004UnpaidBean knLsnUnpaid001Bean) {
        knLsnUnpaid001Mapper.insertInfo(knLsnUnpaid001Bean);
    }

    // 修改支付课费
    private void update(Kn02F004UnpaidBean knLsnUnpaid001Bean) {
        knLsnUnpaid001Mapper.updateInfo(knLsnUnpaid001Bean);
    }

    // 削除支付课费
    public void delete(String lsnPayId, String lsnFeeId) { 
        knLsnUnpaid001Mapper.deleteInfo(lsnPayId, lsnFeeId); 
    }
}
