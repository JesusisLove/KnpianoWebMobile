package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：KN_SAIBAN_001 【採番管理テーブル】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SequencePK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;
    @Column  private String seqid;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SequencePK modelKey = (SequencePK ) o;
        return  Objects.equals(seqid, modelKey.seqid) ;
    }

    @Override
    public int hashCode() {
        return Objects.hash(seqid);
    }
}