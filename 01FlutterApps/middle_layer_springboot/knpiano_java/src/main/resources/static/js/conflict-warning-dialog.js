/**
 * [课程排他状态功能] 2026-02-08 冲突警告对话框
 * 在排课或调课检测到时间冲突时显示警告，让老师确认是否继续
 */

const ConflictWarningDialog = {

  /**
   * 显示冲突警告对话框
   * @param {Array} conflicts 冲突列表
   * @returns {Promise<boolean>} 用户是否确认
   */
  show(conflicts) {
    return new Promise((resolve) => {
      // 创建对话框HTML
      const dialogHtml = `
        <div class="conflict-dialog-overlay" id="conflictDialogOverlay">
          <div class="conflict-dialog">
            <div class="conflict-dialog-header">
              <span class="conflict-icon">&#9888;</span>
              <span class="conflict-title">时间冲突提醒</span>
            </div>
            <div class="conflict-dialog-body">
              <p>您的排课时间与以下课程重叠：</p>
              <ul class="conflict-list">
                ${conflicts.map((c, i) => `
                  <li>
                    <span class="conflict-num">${i + 1}</span>
                    <span class="conflict-info">学生：${c.stuName} &nbsp;&nbsp; 时间：${c.startTime} - ${c.endTime}</span>
                  </li>
                `).join('')}
              </ul>
              <div class="conflict-hint">
                <span class="hint-icon">&#9432;</span>
                <span>集体课可以继续排课，一对一教学建议取消</span>
              </div>
              <p class="conflict-question"><strong>是否继续排课？</strong></p>
            </div>
            <div class="conflict-dialog-footer">
              <button class="btn-cancel" id="conflictCancelBtn">取消</button>
              <button class="btn-confirm" id="conflictConfirmBtn">确认排课</button>
            </div>
          </div>
        </div>
      `;

      // 插入DOM
      document.body.insertAdjacentHTML('beforeend', dialogHtml);

      // 绑定事件
      document.getElementById('conflictCancelBtn').onclick = () => {
        this.close();
        resolve(false);
      };

      document.getElementById('conflictConfirmBtn').onclick = () => {
        this.close();
        resolve(true);
      };
    });
  },

  /**
   * 显示同一学生冲突禁止对话框（不可继续）
   * @param {Array} conflicts 冲突列表
   * @returns {Promise<void>}
   */
  showSameStudentConflict(conflicts) {
    return new Promise((resolve) => {
      const dialogHtml = `
        <div class="conflict-dialog-overlay" id="conflictDialogOverlay">
          <div class="conflict-dialog conflict-dialog-error">
            <div class="conflict-dialog-header conflict-header-error">
              <span class="conflict-icon">&#10060;</span>
              <span class="conflict-title">排课禁止</span>
            </div>
            <div class="conflict-dialog-body">
              <p>同一学生在该时间段已有课程安排：</p>
              <ul class="conflict-list conflict-list-error">
                ${conflicts.map((c) => `
                  <li>
                    <span class="conflict-info">${c.stuName}：${c.startTime} - ${c.endTime}</span>
                  </li>
                `).join('')}
              </ul>
              <div class="conflict-hint conflict-hint-error">
                <span class="hint-icon">&#9432;</span>
                <span>同一学生不能同时上两节课，请选择其他时间</span>
              </div>
            </div>
            <div class="conflict-dialog-footer">
              <button class="btn-confirm btn-error" id="conflictCloseBtn">确定</button>
            </div>
          </div>
        </div>
      `;

      document.body.insertAdjacentHTML('beforeend', dialogHtml);

      document.getElementById('conflictCloseBtn').onclick = () => {
        this.close();
        resolve();
      };
    });
  },

  /**
   * 显示取消调课冲突禁止对话框
   * @param {string} originalTime 原时间段
   * @returns {Promise<void>}
   */
  showCancelRescheduleConflict(originalTime) {
    return new Promise((resolve) => {
      const dialogHtml = `
        <div class="conflict-dialog-overlay" id="conflictDialogOverlay">
          <div class="conflict-dialog">
            <div class="conflict-dialog-header">
              <span class="conflict-icon">&#9888;</span>
              <span class="conflict-title">无法取消调课</span>
            </div>
            <div class="conflict-dialog-body">
              <p>原时间段（${originalTime}）已安排其他学生的课程，无法恢复。</p>
              <div class="conflict-hint">
                <span class="hint-icon">&#9432;</span>
                <span>请保持当前调课状态，或选择其他时间进行调课</span>
              </div>
            </div>
            <div class="conflict-dialog-footer">
              <button class="btn-confirm" id="conflictCloseBtn">确定</button>
            </div>
          </div>
        </div>
      `;

      document.body.insertAdjacentHTML('beforeend', dialogHtml);

      document.getElementById('conflictCloseBtn').onclick = () => {
        this.close();
        resolve();
      };
    });
  },

  /**
   * 关闭对话框
   */
  close() {
    const overlay = document.getElementById('conflictDialogOverlay');
    if (overlay) {
      overlay.remove();
    }
  }
};

/**
 * 课程保存服务（带冲突检测）
 */
const LessonConflictService = {

  /**
   * 保存课程（带冲突检测）
   * @param {string} url API地址
   * @param {Object} lessonData 课程数据
   * @param {boolean} forceOverlap 是否强制保存
   * @returns {Promise<{success: boolean, hasConflict?: boolean, conflicts?: Array, message?: string}>}
   */
  async saveLesson(url, lessonData, forceOverlap = false) {
    lessonData.forceOverlap = forceOverlap;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(lessonData)
      });

      if (response.ok) {
        const result = await response.json();
        return result;
      } else {
        const errorText = await response.text();
        return { success: false, message: errorText };
      }
    } catch (error) {
      return { success: false, message: '网络错误：' + error.message };
    }
  },

  /**
   * 保存课程并处理冲突
   * @param {string} url API地址
   * @param {Object} lessonData 课程数据
   * @param {Function} onSuccess 成功回调
   * @param {Function} onError 错误回调
   */
  async saveLessonWithConflictCheck(url, lessonData, onSuccess, onError) {
    // 第一次调用：检测冲突
    const result = await this.saveLesson(url, lessonData, false);

    if (result.success) {
      // 保存成功
      onSuccess(result);
      return;
    }

    if (result.hasConflict) {
      // 检测到冲突
      if (result.isSameStudentConflict) {
        // 同一学生自我冲突，严格禁止
        await ConflictWarningDialog.showSameStudentConflict(result.conflicts);
      } else {
        // 不同学生冲突，显示警告让用户确认
        const confirmed = await ConflictWarningDialog.show(result.conflicts);

        if (confirmed) {
          // 用户确认继续，强制保存
          const forceResult = await this.saveLesson(url, lessonData, true);
          if (forceResult.success) {
            onSuccess(forceResult);
          } else {
            onError(forceResult.message || '保存失败');
          }
        }
      }
    } else {
      // 其他错误
      onError(result.message || '保存失败');
    }
  }
};
