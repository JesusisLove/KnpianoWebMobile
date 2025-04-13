package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.SequencePK;
import lombok.Data;

import javax.persistence.*;

/* 機能番号：KN_SAIBAN_001 【採番管理テーブル】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "sequence")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = SequencePK.class)
public class Sequence {

    @Id @Column (name = "seqid", length = 50, nullable = false)  protected String seqid;
    @Column (name = "name", length = 50, nullable = false)  protected String name;
    @Column (name = "current_value")  protected Integer currentValue;
    @Column (name = "increment", columnDefinition = "integer default 1")  protected Integer increment;

}
