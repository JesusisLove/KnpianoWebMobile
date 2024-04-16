package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import com.liu.springboot04web.bean.KnFixfLsn001Bean;

public interface KnFixfLsn001Mapper {

    // 获取所有固定授業計画的列表
    public List<KnFixfLsn001Bean> getInfoList();

    // 根据特定条件搜索固定授業計画
    public List<KnFixfLsn001Bean> searchFixedLessons(@Param("params") Map<String, Object> queryparams);

    // 根据学生ID获取固定授業計画详细信息
    public KnFixfLsn001Bean getInfoById(@Param("stuId") String stuId, 
                                        @Param("subjectId") String subjectId, 
                                        @Param("fixedWeek") String fixedWeek);

    // 新增固定授業計画信息
    public void insertInfo(KnFixfLsn001Bean bean);

    // 更新固定授業計画信息
    public void updateInfo(KnFixfLsn001Bean bean);

    // 删除固定授業計画信息
    public void deleteInfoByKeys(@Param("stuId") String stuId, 
                                  @Param("subjectId") String subjectId, 
                                  @Param("fixedWeek") String fixedWeek);

    // 调用数据库序列生成新的ID
    public void getNextSequence(Map<String, Object> map);
}
