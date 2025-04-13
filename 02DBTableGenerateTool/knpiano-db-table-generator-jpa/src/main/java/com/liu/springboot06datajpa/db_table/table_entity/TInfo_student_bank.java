package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_student_bankPK;
import lombok.Data;

import java.sql.Timestamp;

import javax.persistence.*;

/* 機能番号：KN_FIXf_LSN_001 【学生銀行番号管理】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意
@Table(name = "t_info_student_bank")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_student_bankPK.class)
public class TInfo_student_bank {
    @Id @Column (name = "stu_id", length = 32, nullable = false)  protected String stuId;
    @Id @Column (name = "bank_id", length = 32, nullable = false)  protected String bankId;
    @Column (name = "del_flg", columnDefinition = "integer default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP DEFAULT NULL")  protected Timestamp updateDate;
}



