package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_student_documentPK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
 import java.util.Date;

/* 機能番号：KN_BNK_001 【学科基本情報マスタ】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_student_document")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_student_documentPK.class)
public class TInfo_student_document {
    @Id @Column (name = "stu_id", length = 32, nullable = false)  protected String stuId;
    @Id @Column (name = "subject_id", length = 32, nullable = false)  protected String subjectId;
    @Id @Column (name = "adjusted_date")  protected Date adjustedDate;
    @Column (name = "pay_style")  protected Integer payStyle;
    @Column (name = "minutes_per_lsn")  protected Integer minutesPerLsn;
    @Column (name = "lesson_fee")  protected float lessonFee;
    @Column (name = "lesson_fee_adjusted")  protected float lessonFeeAdjusted;
    @Column (name = "del_flg", columnDefinition = "integer default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  protected Timestamp updateDate;
}
