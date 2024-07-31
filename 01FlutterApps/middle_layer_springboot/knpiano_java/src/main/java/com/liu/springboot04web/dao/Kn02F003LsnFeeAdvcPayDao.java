package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;

import com.liu.springboot04web.bean.Kn02F003LsnFeeAdvcPayBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn02F003LsnFeeAdvcPayMapper;

import java.util.List;
import java.util.HashMap;
import java.util.Map;

@Repository
public class Kn02F003LsnFeeAdvcPayDao {
    @Autowired
    private Kn02F003LsnFeeAdvcPayMapper kn02F003LsnFeeAdvcPayMapper;

    @Autowired
    private SqlSessionFactory sqlSessionFactory;

    public List<Kn02F003LsnFeeAdvcPayBean> getAdvcFeePayLsnInfo (String stuId, String yearMonth) {
        return kn02F003LsnFeeAdvcPayMapper.getAdvcFeePayLsnInfo(stuId, yearMonth);
    }

    public Integer executeAdvcLsnFeePay(Kn02F003LsnFeeAdvcPayBean bean) {
        SqlSession session = sqlSessionFactory.openSession();
        try {
            // 创建 Map 对象来接收输出参数
            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("result", null);  // 初始化输出参数为 null
            
            // 调用执行课费预支付的存储过程
            kn02F003LsnFeeAdvcPayMapper.executeAdvcLsnFeePay(
                bean.getStuId(),
                bean.getSubjectId(),
                bean.getSubjectSubId(),
                bean.getLessonType(),
                bean.getSchedualType(),
                bean.getMinutesPerLsn(),
                bean.getSubjectPrice(),
                bean.getSchedualDate(),
                bean.getBankId(),
                KNConstant.CONSTANT_KN_LSN_SEQ,
                KNConstant.CONSTANT_KN_LSN_FEE_SEQ,
                KNConstant.CONSTANT_KN_LSN_PAY_SEQ,
                paramMap
            );
            
            // 获取结果
            Integer result = (Integer) paramMap.get("result");
            return result != null ? result : -1; // 如果结果为 null，返回 -1 或其他适当的默认值
        } finally {
            session.close();
        }
    }
}