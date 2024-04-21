//
//  TextUIView.swift
//  RedBook
//
//  Created by 刘钊 on 2024/4/22.
//

import SwiftUI

struct TextUIView: View {
    // 使用State声明可变的 Binding变量
    @State var username: String = ""
    @State var password: String = ""
    @State var description: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Text(username)
            // 静态的Text
            Text("Hello World!")
                .font(.system(size: 40))
                .fontWeight(.heavy)
                .foregroundColor(Color.green)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .padding([.leading], 5.0)
                .border(.black)
            Text("我要学习swift，学习使我快乐")
                .multilineTextAlignment(.center)
                .lineLimit(1)
            TextField("输入用户名", text: $username)
                .background(.white)
                .textFieldStyle(.plain)
            SecureField("请输入密码", text: $password)
                .background(.white)
                .border(.black)
            TextEditor(text: $description)
                .border(.black)
    }
    }
}

#Preview {
    TextUIView()
}
