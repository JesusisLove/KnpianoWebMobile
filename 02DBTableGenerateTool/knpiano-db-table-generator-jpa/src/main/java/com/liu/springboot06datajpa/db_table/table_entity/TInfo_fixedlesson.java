package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_fixedlessonPK;
import lombok.Data;

import javax.persistence.*;

/* 機能番号：KN_FIXf_LSN_001 【固定授業計画管理】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_fixedlesson")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_fixedlessonPK.class)
public class TInfo_fixedlesson {

    @Id @Column (name = "stu_id", length = 32, nullable = false)  protected String stuId;
    @Id @Column (name = "subject_id", length = 32, nullable = false)  protected String subjectId;
    @Id @Column (name = "fixed_week", length = 2, nullable = false)  protected String fixedWeek;
    @Column (name = "fixed_hour")  protected Integer fixedHour;
    @Column (name = "fixed_minute")  protected Integer fixedMinute;

}
