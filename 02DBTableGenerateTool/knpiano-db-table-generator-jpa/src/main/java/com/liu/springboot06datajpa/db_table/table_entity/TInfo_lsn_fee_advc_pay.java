package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_lsn_fee_advc_payPK;

import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.Date;



/* 機能番号：KN_02F003 【课费预支付管理】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_lsn_fee_advc_pay",
            indexes = @Index(name = "idx_composite_key", columnList = "lsn_fee_id,lesson_id,lsn_pay_id", unique = true))
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_lsn_fee_advc_payPK.class)
public class TInfo_lsn_fee_advc_pay {

    @Id @Column (name = "lsn_fee_id", length = 32, nullable = false)  protected String lsnFeeId;
    @Id @Column (name = "lesson_id", length = 32, nullable = false)  protected String lessonId;
    @Id @Column (name = "lsn_pay_id", length = 32, nullable = false)  protected String lsnPayId;
    @Column (name = "davance_pay_date")  protected Date davancePayDate;
    @Column (name = "advc_flg", columnDefinition = "integer  default 0")  protected Integer advcFlg;
    @Column (name = "del_flg", columnDefinition = "integer  default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP  default CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP  default NULL")  protected Timestamp updateDate;
}
