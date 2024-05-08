package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import com.liu.springboot04web.bean.KnFixLsn001Bean;

public interface KnFixLsn001Mapper {

    // 获取所有固定授業計画的列表
    public List<KnFixLsn001Bean> getInfoList();

    // 获取所有学生最新正在上课的科目信息
    public List<KnFixLsn001Bean> getLatestSubjectList();

    // 根据特定条件搜索固定授業計画
    public List<KnFixLsn001Bean> searchFixedLessons(@Param("params") Map<String, Object> queryparams);

    // 根据学生ID获取固定授業計画详细信息
    public KnFixLsn001Bean getInfoById(@Param("stuId") String stuId, 
                                        @Param("subjectId") String subjectId, 
                                        @Param("fixedWeek") String fixedWeek);

    // 新增固定授業計画信息
    public void insertInfo(KnFixLsn001Bean bean);

    // 更新固定授業計画信息
    public void updateInfo(KnFixLsn001Bean bean);

    // 删除固定授業計画信息
    public void deleteInfoByKeys(@Param("stuId") String stuId, 
                                  @Param("subjectId") String subjectId, 
                                  @Param("fixedWeek") String fixedWeek);

    // 调用数据库序列生成新的ID
    public void getNextSequence(Map<String, Object> map);
}
