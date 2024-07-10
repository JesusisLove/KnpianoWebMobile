package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_lesson_payPK;

import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.Date;

/* 機能番号：KN_LSN_PAY_001 【課費支払管理】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_lesson_pay")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_lesson_payPK.class)
public class TInfo_lesson_pay {

    @Id @Column (name = "lsn_pay_id", length = 32, nullable = false)  protected String lsnPayId;
    @Id @Column (name = "lsn_fee_id", length = 32, nullable = false)  protected String lsnFeeId;
    @Column (name = "lsn_pay")  protected float lsnPay;
    @Column (name = "pay_month", length = 7)  protected String payMonth;
    @Column (name = "pay_date")  protected Date payDate;
    @Column (name = "bank_id", length = 32)  protected String bankId;
    @Column (name = "del_flg", columnDefinition = "integer  default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP  default CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP  default NULL")  protected Timestamp updateDate;
}