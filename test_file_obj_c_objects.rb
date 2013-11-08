framework 'Foundation'

class ObjcObject

  def initialize(objc_instance = nil)
    @objc_instance = objc_instance
  end

  def call_action_on_obj_instance(action="")
    @objc_instance.callWithName(action)
  end

  def append_strings_with_objc(string="")
    @objc_instance.append(string, to: "Bundes")
  end

end