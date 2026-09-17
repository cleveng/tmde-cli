import { useMutation } from '@urql/vue'
import { NButton, NCheckbox, NEmpty, NPagination, NSpace, NTable, useDialog, useMessage } from 'naive-ui'
import { defineComponent, inject, reactive, type Ref } from 'vue'

import { Delete<@ data.pascal_case_name @>Document } from '@/generated/graphql'
import { extractErrorMessage } from '@/plugins'

import { use<@ data.capitalize_name @> } from './<@ data.name @>-provider'

import type { API } from '/#/api'

export default defineComponent({
  name: '<@ data.capitalize_name @>Table',
  props: {
    result: {
      type: Object as PropType<API.Page<API.<@ data.pascal_case_name @>>>,
      required: true
    },
    loadMore: {
      type: Function as PropType<(val: number) => void | Promise<void>>,
      required: false,
      default: () => {}
    }
  },
  setup(props) {
    const dialog = useDialog()
    const message = useMessage()

    const { setOpen, setCurrentRow } = use<@ data.capitalize_name @>()

    const state = reactive({
      loading: false
    })

    const refetch = inject<() => void>('refetch')

    const _todo = inject<Ref<string[]>>('todo')

    const { executeMutation: mutation, fetching } = useMutation(Delete<@ data.pascal_case_name @>Document)

    const onDelete = async (item: API.<@ data.pascal_case_name @>) => {
      dialog.warning({
        title: '是否删除?',
        content: '删除后无法恢复，请谨慎操作',
        positiveText: '确 认',
        negativeText: '取 消',
        draggable: true,
        onPositiveClick: async () => {
		      if (state.loading) return
		      state.loading = true

		      try {
		        const res = await mutation({ id: item.id })
		        if (res.error) {
		          const title = extractErrorMessage(res.error)
		          message.error(title)
		          return
		        }

		        if (res.data?.delete<@ data.pascal_case_name @>) {
		          message.success("删除成功")
		          refetch?.()
		        }
		      } catch (error) {
		        console.error(error)
		      } finally {
		        state.loading = false
		      }
        }
      })
    }

    return () => (
      <div class='w-full overflow-x-auto'>
        <NTable singleLine={false}>
          <thead>
            <tr>
              <th>
                <NCheckbox disabled />
              </th>
              <th>ID</th>
              <th>字段一</th>
              <th>字段二</th>
              <th>字段三</th>
              <th>字段四</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            {props.result.data?.length === 0 ? (
              <tr>
                <td colspan={7}>
                  <div class='py-24 text-center'>
                    <NEmpty description='暂无数据，请先添加' />
                  </div>
                </td>
              </tr>
            ) : (
              props.result.data?.map(item => (
                <tr key={item.id}>
                  <td>
                    <NCheckbox disabled />
                  </td>
                  <td class='whitespace-nowrap'>{item.id}</td>
                  <td class='whitespace-nowrap'>字段一</td>
                  <td class='whitespace-nowrap'>字段二</td>
                  <td class='whitespace-nowrap'>字段三</td>
                  <td class='whitespace-nowrap'>字段四</td>
                  <td>
                    <NSpace align='center'>
                      <NButton
                        size='small'
                        onClick={() => {
                          setCurrentRow(item)
                          setOpen('edit')
                        }}
                      >
                        编 辑
                      </NButton>
                      <NButton size='small' disabled={fetching.value} type='error' onClick={() => onDelete(item)}>
                        删 除
                      </NButton>
                    </NSpace>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </NTable>

        <NSpace class='mt-8 justify-between'>
          <span class='text-base'>共有数据: {props.result.total} 条</span>
          {props.result.lastPage > 1 && (
            <div class='flex justify-center'>
              <NPagination
                itemCount={props.result.total}
                page={props.result.currentPage}
                pageSize={props.result.perPage}
                onUpdate:page={($event: number) => {
                  if (props.loadMore) {
                    props.loadMore($event)
                  }
                }}
              />
            </div>
          )}
        </NSpace>
      </div>
    )
  }
})
