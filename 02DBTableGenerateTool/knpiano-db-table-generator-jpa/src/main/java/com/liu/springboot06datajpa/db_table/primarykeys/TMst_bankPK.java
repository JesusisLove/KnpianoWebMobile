package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：CT_KEIYAKU_007 【口座管理】テーブルPKクラス */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TMst_bankPK implements Serializable  {
    private static final long serialVersionUID = -2397232644712659215L;
    @Column
    private String bankId;
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TMst_bankPK modelKey = (TMst_bankPK) o;
        return  Objects.equals(bankId, modelKey.bankId);
    }
    @Override
    public int hashCode() {
        return Objects.hash(bankId);
    }

}
