package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_lesson_feePK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
// import java.util.Date;


/* 機能番号：KN_LSN_FEE_001 【課費情報管理】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_lesson_fee")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_lesson_feePK.class)
public class TInfo_lesson_fee {

    @Id @Column (name = "lsn_fee_id", length = 32, nullable = false)  protected String lsnFeeId;
    @Id @Column (name = "lesson_id", length = 32, nullable = false)  protected String lessonId;
    @Column (name = "pay_style")  protected Integer payStyle;
    @Column (name = "lsn_fee")  protected float lsnFee;
    @Column (name = "lsn_month", length = 7)  protected String lsnMonth;
    @Column (name = "own_flg")  protected Integer ownFlg;
    @Column (name = "del_flg", columnDefinition = "integer default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP  default CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP  default NULL")  protected Timestamp updateDate;

}
